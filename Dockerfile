# Base image with Culture enabled

FROM mcr.microsoft.com/dotnet/aspnet:7.0.0-preview.6-alpine3.16 as base
    WORKDIR /app
    ENV ASPNETCORE_ENVIRONMENT=Production \
        ASPNETCORE_URLS=https://*:7086;http://*:5086 \
        ASPNETCORE_Kestrel__Certificates__Default__Password="12345" \
        ASPNETCORE_Kestrel__Certificates__Default__Path="https.pfx" \
        DOTNET_RUNNING_IN_CONTAINER=true
    RUN apk add --no-cache icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib

# Copy projects, restore and compile in release

FROM mcr.microsoft.com/dotnet/sdk:7.0.100-preview.6-alpine3.16 as build
    WORKDIR /src

    RUN mkdir Shared
    RUN mkdir Client
    RUN mkdir Server

    COPY ["Shared/BlazorAppTestDocker.Shared.csproj", "Shared"]
    COPY ["Client/BlazorAppTestDocker.Client.csproj", "Client"]
    COPY ["Server/BlazorAppTestDocker.Server.csproj", "Server"]

    RUN dotnet restore "Server/BlazorAppTestDocker.Server.csproj"
    RUN dotnet restore "Shared/BlazorAppTestDocker.Shared.csproj"
    RUN dotnet restore "Client/BlazorAppTestDocker.Client.csproj"

    COPY ["./Server", "Server"]
    COPY ["./Shared", "Shared"]
    COPY ["./Client", "Client"]

    RUN dotnet build "./Server/BlazorAppTestDocker.Server.csproj" -c Release -o "/app/build"

# Publish

FROM build as publish
    RUN dotnet publish "Server/BlazorAppTestDocker.Server.csproj" -c Release -o "/app/publish"

# Run

FROM base as final
    WORKDIR /app

    COPY --from=publish /app/publish .
    ENTRYPOINT ["dotnet", "BlazorAppTestDocker.Server.dll"]

