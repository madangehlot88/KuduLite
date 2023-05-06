#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.


FROM ubuntu:latest
RUN apt-get -y update
RUN apt-get -y install git

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Kudu.Services.Web/Kudu.Services.Web.csproj", "Kudu.Services.Web/"]
COPY ["Kudu.Core/Kudu.Core.csproj", "Kudu.Core/"]
COPY ["Kudu.Contracts/Kudu.Contracts.csproj", "Kudu.Contracts/"]
COPY ["Kudu.Services/Kudu.Services.csproj", "Kudu.Services/"]
COPY ["Kudu.Console/Kudu.Console.csproj", "Kudu.Console/"]
RUN dotnet restore "Kudu.Services.Web/Kudu.Services.Web.csproj"
COPY . .
WORKDIR "/src/Kudu.Services.Web"
RUN dotnet build "Kudu.Services.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Kudu.Services.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Kudu.Services.Web.dll"]