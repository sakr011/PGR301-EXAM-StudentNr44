# Step 1: Build stage
FROM maven:3.9.9-amazoncorretto-17 as builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven POM file and the source code to the container
COPY pom.xml ./
COPY src ./src/

# Build the application using Maven
RUN mvn clean package -DskipTests

# Step 2: Run stage (use a minimal runtime image)
FROM openjdk:17-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=builder /app/target/imagegenerator-0.0.1-SNAPSHOT.jar ./imagegenerator.jar


# Sett miljøvariabelen for SQS URL (denne kan overstyres ved kjøretid)
ENV SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/244530008913/44-image-generation-queue

# Command to run the application
ENTRYPOINT ["java", "-jar", "imagegenerator.jar"]

# Optional: Expose a port if needed (e.g., for API interaction)
# EXPOSE 8080