workspace "EDIFIKA" "Diagrama de Contenedores de la plataforma EDIFIKA con extension IoT" {

    model {
        // ==========================================
        // Actores / Personas
        // ==========================================
        admin = person "Administrator" "Manages residents, payments, units, reservations, official announcements, building forum, report generation, and IoT automation rules." "Person"
        resident = person "Owner or Tenant" "Checks debts, makes payments, reserves common areas, accesses spaces via RFID/QR, interacts with lighting, and participates in the building forum." "Person"

        // ==========================================
        // Sistemas externos
        // ==========================================
        culqi = softwareSystem "Culqi" "External payment gateway used to process online payments for maintenance fees, debts, and services." "External"
        cloudinary = softwareSystem "Cloudinary" "External cloud service used to store, optimize, and deliver images uploaded in forum posts and official announcements." "External"
        fcm = softwareSystem "Firebase Cloud Messaging" "External push notification service used to deliver real-time notifications to mobile apps." "External"

        // ==========================================
        // Sistema principal EDIFIKA
        // ==========================================
        edifika = softwareSystem "EDIFIKA" {
            // Contenedores Frontend
            mobileApp = container "Mobile Application" "Allows administrators, owners, and tenants to make payments, reservations, announcements, dynamic QR access generation, and forum interaction from iOS and Android devices." "Flutter / Mobile App" "Mobile App"
            webApp = container "Web Application" "Allows administrators, owners, and tenants to access payments, reservations, announcements, IoT telemetry dashboards, and reports from a web browser." "Angular / SPA" "Web App"

            // API Gateway
            apiGateway = container "API Gateway" "Single entry point for requests from the mobile and web applications. Centralizes routing, security, rate limiting, and JWT token validation." "Spring Cloud Gateway / Node.js" "API Gateway"

            // Microservicios de Gestion Administrativa (Existentes)
            iamService = container "IAM / Auth Service" "Manages authentication, authorization, user roles, and issues/validates using JWT." "Spring Boot / Node.js" "Microservice"
            residentialService = container "Residential Management Service" "Manages buildings, units, residents, and the relationships between users and apartments." "Spring Boot / Node.js" "Microservice"
            paymentService = container "Payment Service" "Manages debts, fees, payments, receipts, and integration with Culqi." "Spring Boot / Node.js" "Microservice"
            reservationService = container "Reservation Service" "Manages common areas, availability, reservations, approvals, and cancellations." "Spring Boot / Node.js" "Microservice"
            communicationService = container "Communication Service" "Publishes official announcements, administrative notices, and fluid communication." "Spring Boot / Node.js" "Microservice"
            forumService = container "Messaging / Forum Service" "Manages posts, comments, and interactions between residents within each building's private forum." "Spring Boot / Node.js" "Microservice"
            notificationService = container "Notification Service" "Consumes system events and sends push notifications related to payments, reservations, announcements, and IoT alerts." "Spring Boot / Node.js" "Microservice"
            reportService = container "Report Service" "Generates comprehensive reports about payments, overdue debts, reservations, and community analytics." "Spring Boot / Node.js" "Microservice"

            // Nuevos Microservicios IoT Cloud
            accessService = container "IoT Access Management Service" "Manages common area access permissions, RFID and dynamic QR credentials, and door locks based on active reservations." "Spring Boot / Node.js" "IoT Microservice"
            lightingService = container "Smart Lighting & Automation Service" "Controls common area luminaires based on presence detection, ambient lux levels, reservation schedules, and manual override." "Spring Boot / Node.js" "IoT Microservice"
            telemetryService = container "IoT Telemetry & Analytics Service" "Ingests sensor telemetry, performs quantitative energy calculations (kWh), computes statistics, and flags hardware anomalies." "Spring Boot / Node.js" "IoT Microservice"

            // Broker de Mensajería y Bases de Datos
            messageBroker = container "Message & Event Broker" "Receives and distributes asynchronous domain events (AMQP/MQTT) such as payments, reservations, sensor telemetry, and actuator commands." "EMQX / RabbitMQ" "Message Broker"
            database = container "PostgreSQL Database" "Stores users, buildings, units, debts, payments, reservations, announcements, forum posts, notifications, and access credentials." "PostgreSQL / Relational Database" "Database"
            telemetryDatabase = container "Telemetry Database" "Stores high-frequency sensor readings, presence logs, power consumption metrics, and environmental series." "TimescaleDB / PostgreSQL" "Database"

            // Nivel Edge Computing (Instalado en Condominio)
            edgeGateway = container "Edge API & Gateway Controller" "On-premise edge gateway running on-site. Provides offline credential caching, local device coordination, and resilient operation during internet outages." "FastAPI / Python" "Edge Gateway"

            // Dispositivos Fisicos Embebidos (IoT Devices)
            accessDevice = container "Common Area Access Controller" "Physical IoT embedded device with RFID reader (RC522), QR scanner, magnetic door sensor, buzzer, and electric lock relay." "ESP32 / Embedded C++" "IoT Device"
            lightingDevice = container "Smart Lighting & Sensing Node" "Physical IoT embedded node equipped with PIR presence sensor, LDR lux sensor, ACS712 current sensor, and luminaire relay." "ESP32 / Embedded C++" "IoT Device"
        }

        // ==========================================
        // Relaciones: Usuarios -> Frontend
        // ==========================================
        admin -> mobileApp "Interacts to manage condominium operations, approve reservations, and monitor alerts"
        resident -> mobileApp "Checks debts, makes payments, reserves areas, generates QR access tokens, and triggers lights"

        admin -> webApp "Manages condominium, configures automation rules, and analyzes energy telemetry"
        resident -> webApp "Checks debts, makes payments, reserves areas, and reviews announcements"

        // ==========================================
        // Frontend -> API Gateway
        // ==========================================
        mobileApp -> apiGateway "Consumes REST services by sending a JWT token" "JSON/HTTPS"
        webApp -> apiGateway "Consumes REST services by sending a JWT token" "JSON/HTTPS"

        // ==========================================
        // API Gateway -> Microservicios
        // ==========================================
        apiGateway -> iamService "Redirects authentication and authorization requests" "HTTPS/REST"
        apiGateway -> residentialService "Redirects residential management requests" "HTTPS/REST"
        apiGateway -> paymentService "Redirects payment and debt requests" "HTTPS/REST"
        apiGateway -> reservationService "Redirects reservation requests" "HTTPS/REST"
        apiGateway -> communicationService "Redirects official announcement requests" "HTTPS/REST"
        apiGateway -> forumService "Redirects forum post, comment, and like requests" "HTTPS/REST"
        apiGateway -> notificationService "Redirects notification-related requests" "HTTPS/REST"
        apiGateway -> reportService "Redirects report generation requests" "HTTPS/REST"
        apiGateway -> accessService "Redirects access permission, credential, and door control requests" "HTTPS/REST"
        apiGateway -> lightingService "Redirects lighting schedules and manual override requests" "HTTPS/REST"
        apiGateway -> telemetryService "Redirects telemetry query and energy analytics requests" "HTTPS/REST"

        // ==========================================
        // Integraciones Externas
        // ==========================================
        paymentService -> culqi "Processes online payments" "HTTPS/REST"
        communicationService -> cloudinary "Uploads and retrieves images associated with official announcements" "HTTPS/REST"
        forumService -> cloudinary "Uploads and retrieves images associated with forum posts" "HTTPS/REST"
        notificationService -> fcm "Sends push notifications of system events to mobile users" "HTTPS/REST"

        // ==========================================
        // Microservicios -> Message Broker (Publicacion)
        // ==========================================
        paymentService -> messageBroker "Publishes PaymentRegistered, PaymentConfirmed, and ResidentMarkedDelinquent events" "AMQP"
        reservationService -> messageBroker "Publishes ReservationCreated, ReservationCancelled, and ReservationApproved events" "AMQP"
        communicationService -> messageBroker "Publishes AnnouncementPublished events" "AMQP"
        forumService -> messageBroker "Publishes ForumPostCreated and ForumCommentCreated events" "AMQP"
        accessService -> messageBroker "Publishes PhysicalAccessGranted and PhysicalAccessDenied events" "AMQP/MQTT"
        lightingService -> messageBroker "Publishes LuminaireTurnedOn, LuminaireTurnedOff, and OverrideTriggered events" "AMQP/MQTT"
        telemetryService -> messageBroker "Publishes AbnormalConsumptionDetected and LuminaireFailureDetected events" "AMQP/MQTT"

        // ==========================================
        // Message Broker -> Microservicios (Consumo)
        // ==========================================
        messageBroker -> notificationService "Delivers events that require user notifications" "AMQP"
        messageBroker -> reportService "Delivers events for report aggregation and statistics" "AMQP"
        messageBroker -> accessService "Consumes ReservationApproved and ResidentMarkedDelinquent events to update access rules" "AMQP"
        messageBroker -> lightingService "Consumes AreaPresenceDetected and ReservationStarted events to trigger lights" "AMQP/MQTT"
        messageBroker -> telemetryService "Consumes raw sensor readings and power telemetry for quantitative aggregation" "MQTT"

        // ==========================================
        // Microservicios -> Bases de Datos
        // ==========================================
        iamService -> database "Reads and writes users, roles, and credentials" "JDBC/SQL"
        residentialService -> database "Reads and writes buildings, units, and residents" "JDBC/SQL"
        paymentService -> database "Reads and writes debts, payments, and transactions" "JDBC/SQL"
        reservationService -> database "Reads and writes common areas and reservations" "JDBC/SQL"
        communicationService -> database "Reads and writes official announcements with image references" "JDBC/SQL"
        forumService -> database "Reads and writes forum posts, comments, reactions, and image references" "JDBC/SQL"
        notificationService -> database "Reads and writes notification history and preferences" "JDBC/SQL"
        reportService -> database "Queries for cumulative reports" "JDBC/SQL"
        accessService -> database "Reads and writes access credentials, permissions, and audit logs" "JDBC/SQL"
        lightingService -> database "Reads and writes lighting policies, schedules, and device configs" "JDBC/SQL"
        telemetryService -> telemetryDatabase "Writes high-frequency telemetry samples and queries statistical aggregations" "JDBC/SQL"

        // ==========================================
        // Sincronizacion Cloud <-> Edge Gateway
        // ==========================================
        accessService -> edgeGateway "Synchronizes active access credentials, active reservations, and blacklist" "HTTPS/REST Sync"
        edgeGateway -> messageBroker "Forwards offline access audit logs and buffered sensor telemetry" "MQTT/AMQP WAN"
        lightingService -> edgeGateway "Sends automated scheduling rules and manual override commands" "MQTT/REST"

        // ==========================================
        // Edge Gateway <-> Dispositivos Fisicos Embebidos
        // ==========================================
        accessDevice -> edgeGateway "Sends access attempt (UID/QR token) and door contact state" "MQTT/HTTP Local"
        edgeGateway -> accessDevice "Sends door unlock pulse command and buzzer/LED feedback" "MQTT/HTTP Local"
        lightingDevice -> edgeGateway "Sends periodic presence events, ambient lux, and power current readings" "MQTT/HTTP Local"
        edgeGateway -> lightingDevice "Sends luminaire on/off and brightness PWM commands" "MQTT/HTTP Local"

        // ==========================================
        // Interaccion Fisica de Usuarios con Hardware
        // ==========================================
        resident -> accessDevice "Presents RFID card or scans dynamic QR code at common area door" "Physical/RFID"
        resident -> lightingDevice "Generates physical motion detected by PIR presence sensor" "Physical/Infrared"
    }

    views {
        container edifika "Containers" {
            include *
            autoLayout lr
        }

        styles {
            // Actores
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
                fontSize 22
            }

            // Sistemas Externos
            element "External" {
                shape RoundedBox
                background #64748b
                color #ffffff
            }

            // Frontend Clients
            element "Web App" {
                shape WebBrowser
                background #2563eb
                color #ffffff
            }
            element "Mobile App" {
                shape MobileDevicePortrait
                background #0284c7
                color #ffffff
            }

            // API Gateway
            element "API Gateway" {
                shape RoundedBox
                background #0d9488
                color #ffffff
                stroke #115e59
                strokeWidth 2
            }

            // Microservicios de Gestion Clasica
            element "Microservice" {
                shape RoundedBox
                background #1e40af
                color #ffffff
                stroke #1e3a8a
                strokeWidth 1
            }

            // Nuevos Microservicios IoT Cloud
            element "IoT Microservice" {
                shape RoundedBox
                background #16a34a
                color #ffffff
                stroke #14532d
                strokeWidth 2
            }

            // Message Broker (Estilos destacados solicitados)
            element "Message Broker" {
                shape Pipe
                background #8e44ad
                color #ffffff
                stroke #5b2c6f
                strokeWidth 3
            }

            // Bases de Datos
            element "Database" {
                shape Cylinder
                background #004d80
                color #ffffff
                stroke #002b47
                strokeWidth 2
            }

            // Nivel Edge Computing
            element "Edge Gateway" {
                shape Hexagon
                background #ea580c
                color #ffffff
                stroke #9a3412
                strokeWidth 2
            }

            // Dispositivos Fisicos Embebidos IoT
            element "IoT Device" {
                shape Component
                background #dc2626
                color #ffffff
                stroke #7f1d1d
                strokeWidth 2
            }
        }
    }
}
