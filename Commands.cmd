docker build -t netdefender/docker-blazor-test:1.0.0 .
docker run -d --name docker-blazor-test -p 7086:7086 -p 5086:5086 netdefender/docker-blazor-test:1.0.0

REM Browse http://localhost:5086 or https://localhost:7086