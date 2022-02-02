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