FROM golang:1.15 as BUILD
WORKDIR /src
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 go build -o /bin/app .
FROM alpine
WORKDIR /app
COPY --from=BUILD /bin/app .
RUN chmod +x app
ENTRYPOINT ["./app"]
CMD [""]