## PostgreSQL



Запуск **PostgreSQL** с паролем

в **Windows Powershell**
```shell
docker run -d `
  --name my-postgres `
  -p 5432:5432 `
  -e POSTGRES_PASSWORD=mysecretpassword `
  postgres:alpine
```
![alt text](img/postgres/2026-03-31_10-50-57.png)

Подключиться через `psql`
```shell
docker exec -it my-postgres psql -U postgres
```
![alt text](img/postgres/2026-03-31_10-51-22.png)

Получить список баз данных:
```sql
\l
```

![alt text](img/postgres/2026-03-31_10-51-49.png)

Получить версию:
```sql
SELECT version();
```
![alt text](img/postgres/2026-03-31_10-52-18.png)

выйти из БД
```sql
exit
```
