package main

import (
	"context"
	"database/sql"
	"encoding/csv"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/google/uuid"
	_ "github.com/lib/pq"
)

func downloadFile(sess *session.Session, bucket, key string) (string, error) {
	downloader := s3manager.NewDownloader(sess)
	fname := fmt.Sprintf("/tmp/%s.csv", uuid.New().String())
	f, err := os.Create(fname)
	if err != nil {
		return "", err
	}
	defer f.Close()
	_, err = downloader.Download(f, &s3.GetObjectInput{ // it must be return n
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return "", err
	}
	return fname, nil
}

func connectDb() (*sql.DB, error) {
	psqlInfo := fmt.Sprintf("host=%s port=%s user=%s "+
		"password=%s dbname=%s sslmode=disable",
		os.Getenv("PSQL_HOST"), os.Getenv("PSQL_PORT"), os.Getenv("PSQL_USER"), os.Getenv("PSQL_PASS"), os.Getenv("PSQL_DB"))
	return sql.Open("postgres", psqlInfo)
}

func readCsvFile(filePath string) ([][]string, error) {
	f, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	csvReader := csv.NewReader(f)
	records, err := csvReader.ReadAll()
	if err != nil {
		return nil, err
	}

	return records, nil
}

func writeToDB(ctx context.Context, db *sql.DB, records [][]string) error {
	tx, err := db.BeginTx(ctx, &sql.TxOptions{})
	if err != nil {
		return fmt.Errorf("db.BeginTx failed w err: %w", err)
	}
	insertQuery := `INSERT INTO http_logs (method, endpoint, status_code, metric_name, metric_value) VALUES ($1, $2, $3, $4, $5)`
	for i, record := range records {
		// continue header
		if i == 0 {
			continue
		}
		_, err := tx.ExecContext(ctx, insertQuery, record[0], record[1], record[2], record[3], record[4])
		if err != nil {
			tx.Rollback()
			return err
		}
	}
	return tx.Commit()
}

func handler(ctx context.Context, s3Event events.S3Event) error {
	sess := session.Must(session.NewSession())
	db, err := connectDb()
	if err != nil {
		return fmt.Errorf("connectDb failed w err: %w", err)
	}
	if err := createTableIfNotExists(ctx, db); err != nil {
		return fmt.Errorf("createTableIfNotExists failed w err: %w", err)
	}
	for _, record := range s3Event.Records {
		s3 := record.S3
		fname, err := downloadFile(sess, s3.Bucket.Name, s3.Object.Key)
		if err != nil {
			fmt.Printf("download file failed w err: %v", err)
			return fmt.Errorf("download file failed w err: %w", err)
		}
		records, err := readCsvFile(fname)
		if err != nil {
			fmt.Printf("readCsvFile failed w err: %v", err)
			return fmt.Errorf("readCsvFile failed w err: %w", err)
		}
		if err := writeToDB(ctx, db, records); err != nil {
			return fmt.Errorf("writeToDB failed w error: %w", err)
		}
		fmt.Println("Success! CSV file migrated to RDS!")
	}
	return nil
}

func createTableIfNotExists(ctx context.Context, db *sql.DB) error {
	createSQL := `
	create table if not exists http_logs 	(
			id serial
				constraint http_logs_pk
					primary key,
			method char(50),
			endpoint char(100),
			status_code int,
			metric_name char(100),
			metric_value char(100)
		);
	`
	_, err := db.ExecContext(ctx, createSQL)
	return err
}

func main() {
	lambda.Start(handler)
}
