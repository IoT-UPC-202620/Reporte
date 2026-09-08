workspace "EDIFIKA" "Diagrama de Contenedores de la plataforma EDIFIKA" {

    model {
        // Actores / Personas
        admin = person "Administrator" "Manages residents, payments, units, reservation, official announcements, the building forum, and customizable report generation."
        resident = person "Owner or Tenant" "Checks debts, makes payments, reserves common areas, receives official announcements, and participates in the building forum."

        // Sistemas externos
        culqi = softwareSystem "Culqi" "External payment gateway used to process online payments for maintenance fees, debts, and services." "External"
        cloudinary = softwareSystem "Cloudinary" "External cloud service used to store, optimize, and deliver images uploaded in forum posts and official announcements." "External"
        fcm = softwareSystem "Firebase Cloud Messaging" "External push notification service used to deliver real-time notifications to mobile apps." "External"

        // Sistema principal EDIFIKA
        edifika = softwareSystem "EDIFIKA" {
            // Contenedores Frontend
            mobileApp = container "Mobile Application" "Allows administrators, owners, and tenants to make payments, reservations, announcements, building forum, and reports from iOS and Android devices." "Flutter / Mobile App"
            webApp = container "Web Application" "Allows administrators, owners, and tenants to access payments, reservations, announcements, building forum, and reports from a web browser." "Angular / SPA"

            // Contenedores Backend / Microservicios
            apiGateway = container "API Gateway" "Single entry point for requests from the mobile and web applications. Centralizes routing, security, and JWT token validation." "Spring Cloud Gateway / Node.js"

            iamService = container "IAM / Auth Service" "Manages authentication, authorization, user roles, and issues/validates using JWT." "Spring Boot / Node.js"
            residentialService = container "Residential Management Service" "Manages buildings, units, residents, and the relationships between users and apartments." "Spring Boot / Node.js"
            paymentService = container "Payment Service" "Manages debts, fees, payments, receipts, and integration with Culqi." "Spring Boot / Node.js"
            reservationService = container "Reservation Service" "Manages common areas, availability, reservations, approvals, approvals, and cancellations." "Spring Boot / Node.js"
            communicationService = container "Communication Service" "Publishes official announcements, administrative notices, and fluid communication." "Spring Boot / Node.js"
            forumService = container "Messaging / Forum Service" "Manages posts, comments, and interactions between residents within each building's private forum." "Spring Boot / Node.js"
            notificationService = container "Notification Service" "Consumes system events and sends notifications related to payments, reservations, announcements, and forum activity." "Spring Boot / Node.js"
            reportService = container "Report Service" "Generates comprehensive reports about payments, overdue debts, reservations, announcements, and collaborative activity." "Spring Boot / Node.js"

            // Broker y Base de Datos
            messageBroker = container "Message Broker" "Receives and distributes asynchronous domain events such as payments processed, reservations created, announcements published, and forum activity." "RabbitMQ / Kafka"
            database = container "PostgreSQL Database" "Stores users, fines, buildings, units, debts, payments, reservations, announcements, forum posts, comments, read confirmations, notifications, image references, and report data." "PostgreSQL / Relational Database" "Database"
        }

        // Relaciones: Usuarios -> Frontend
        admin -> mobileApp "Interacts to manage the condominium (debts, payments, reservations, announcements, and forum) via the Forum"
        resident -> mobileApp "Interacts to check information, make payments, and participate via the Forum"

        admin -> webApp "Interacts to manage the condominium (debts, payments, reservations, announcements, and forum) via the Forum"
        resident -> webApp "Interacts to check information, make payments, and participate via the Forum"

        // Frontend -> API Gateway
        mobileApp -> apiGateway "Consumes REST services by sending a JWT token" "JSON/HTTPS"
        webApp -> apiGateway "Consumes REST services by sending a JWT token" "JSON/HTTPS"

        // API Gateway -> Microservicios
        apiGateway -> iamService "Redirects authentication and authorization requests" "HTTPS/REST"
        apiGateway -> residentialService "Redirects residential management requests" "HTTPS/REST"
        apiGateway -> paymentService "Redirects payment and debt requests" "HTTPS/REST"
        apiGateway -> reservationService "Redirects reservation requests" "HTTPS/REST"
        apiGateway -> communicationService "Redirects official announcement requests" "HTTPS/REST"
        apiGateway -> forumService "Redirects forum post, comment, and like requests" "HTTPS/REST"
        apiGateway -> notificationService "Redirects notification-related requests" "HTTPS/REST"
        apiGateway -> reportService "Redirects report generation requests" "HTTPS/REST"

        // Integraciones Externas
        paymentService -> culqi "Processes online payments" "HTTPS/REST"
        communicationService -> cloudinary "Uploads and retrieves images associated with official announcements" "HTTPS/REST"
        forumService -> cloudinary "Uploads and retrieves images associated with forum posts" "HTTPS/REST"
        notificationService -> fcm "Sends push notifications of system events to mobile users" "HTTPS/REST"

        // Microservicios -> Message Broker (Publicación)
        paymentService -> messageBroker "Publishes PaymentRegistered and PaymentConfirmed events" "AMQP"
        reservationService -> messageBroker "Publishes ReservationCreated, ReservationCancelled, and ReservationApproved events" "AMQP"
        communicationService -> messageBroker "Publishes AnnouncementPublished events" "AMQP"
        forumService -> messageBroker "Publishes ForumPostCreated and ForumCommentCreated events" "AMQP"

        // Message Broker -> Microservicios (Consumo)
        messageBroker -> notificationService "Delivers events that require user notifications" "AMQP"
        messageBroker -> reportService "Delivers events for report aggregation and statistics" "AMQP"

        // Microservicios -> Base de Datos
        iamService -> database "Reads and writes users, roles, and credentials" "JDBC/SQL"
        residentialService -> database "Reads and writes buildings, units, and residents" "JDBC/SQL"
        paymentService -> database "Reads and writes debts, payments, and transactions" "JDBC/SQL"
        reservationService -> database "Reads and writes common areas and reservations" "JDBC/SQL"
        communicationService -> database "Reads and writes official announcements with image references" "JDBC/SQL"
        forumService -> database "Reads and writes forum posts, comments, reactions, and image references" "JDBC/SQL"
        notificationService -> database "Reads and writes notification history and preferences" "JDBC/SQL"
        reportService -> database "Queries for cumulative reports" "JDBC/SQL"
    }

    views {
        container edifika "Containers" {
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #004d80
                color #ffffff
            }
            element "Flutter / Mobile App" {
                shape MobileDevicePortrait
                background #2d88ff
                color #ffffff
            }
            element "Angular / SPA" {
                shape WebBrowser
                background #2d88ff
                color #ffffff
            }
            element "RabbitMQ / Kafka" {
                shape Pipe
                background #8e44ad
                color #ffffff
            }
        }
    }
}
