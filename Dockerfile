# ---------- Stage 1: Build ----------
FROM maven:3.9.4-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy only pom.xml first for layer caching
COPY pom.xml .

# Download dependencies (better layer caching)
RUN mvn dependency:go-offline

# Now copy rest of the code
COPY src ./src

# Build the app (skip tests for speed)
RUN mvn clean package -DskipTests

# ---------- Stage 2: Run ----------
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

# Copy the built jar
COPY --from=builder /app/target/*.jar app.jar

# Expose the Eureka port
EXPOSE 8761

# Run the app with docker profile
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]
