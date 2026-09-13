workspace "EDIFIKA" "System Landscape, Context, Container and Deployment diagrams for the EDIFIKA platform with IoT extension" {

    model {
        // ==========================================
        // Actores / Personas
        // ==========================================
        admin = person "Administrator" "Manages residents, payments, units, reservations, official announcements, building forum, report generation, and IoT automation rules." "Person"
        resident = person "Owner or Tenant" "Checks debts, makes payments, reserves common areas, accesses spaces via RFID/QR, interacts with lighting, and participates in the building forum." "Person"
        visitor = person "Visitor" "Anonymous prospect who browses the EDIFIKA static Landing Page to learn about the business model before signing up." "Person"

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
            // Landing Page (producto estatico independiente, parte del alcance)
            landingPage = container "Landing Page" "Static marketing website presenting the EDIFIKA business model, target segments, and pricing, with call-to-action buttons for each segment." "HTML5 / CSS3 / JavaScript" "Landing Page"

            // Contenedores Frontend
            mobileApp = container "Mobile Application" "Allows administrators, owners, and tenants to make payments, reservations, announcements, dynamic QR access generation, and forum interaction from iOS and Android devices." "Flutter / Dart" "Mobile App"
            webApp = container "Web Application" "Allows administrators, owners, and tenants to access payments, reservations, announcements, IoT telemetry dashboards, and reports from a web browser." "Angular / TypeScript / SPA" "Web App"

            // API Gateway
            apiGateway = container "API Gateway" "Single entry point for requests from the mobile and web applications. Centralizes routing, security, rate limiting, and JWT token validation." "Spring Cloud Gateway / Java" "API Gateway"

            // Microservicios de Gestion Administrativa (Existentes)
            iamService = container "IAM / Auth Service" "Manages authentication, authorization, user roles, and issues/validates using JWT." "Spring Boot / Spring Data JPA / Java" "Microservice"
            residentialService = container "Residential Management Service" "Manages buildings, units, residents, and the relationships between users and apartments." "Spring Boot / Spring Data JPA / Java" "Microservice"
            paymentService = container "Payment Service" "Manages debts, fees, payments, receipts, and integration with Culqi." "Spring Boot / Spring Data JPA / Java" "Microservice"
            reservationService = container "Reservation Service" "Manages common areas, availability, reservations, approvals, and cancellations." "Spring Boot / Spring Data JPA / Java" "Microservice"
            communicationService = container "Communication Service" "Publishes official announcements, administrative notices, and fluid communication." "Spring Boot / Spring Data JPA / Java" "Microservice"
            forumService = container "Messaging / Forum Service" "Manages posts, comments, and interactions between residents within each building's private forum." "Spring Boot / Spring Data JPA / Java" "Microservice"
            notificationService = container "Notification Service" "Consumes system events and sends push notifications related to payments, reservations, announcements, and IoT alerts." "Spring Boot / Spring Data JPA / Java" "Microservice"
            reportService = container "Report Service" "Generates comprehensive reports about payments, overdue debts, reservations, and community analytics." "Spring Boot / Spring Data JPA / Java" "Microservice"

            // Nuevos Microservicios IoT Cloud
            accessService = container "IoT Access Management Service" "Manages common area access permissions, RFID and dynamic QR credentials, and door locks based on active reservations." "Spring Boot / Spring Data JPA / Java" "IoT Microservice" {
                accessCredentialController = component "AccessCredentialController" "Issues, suspends, and revokes RFID/QR access credentials." "Spring MVC REST Controller" "Component"
                qrAccessController = component "QrAccessController" "Generates the dynamic, single-use QR token a resident presents at the door." "Spring MVC REST Controller" "Component"
                doorControlController = component "DoorControlController" "Allows an administrator to remotely open a common area door." "Spring MVC REST Controller" "Component"
                accessAuditController = component "AccessAuditController" "Exposes the access-attempt audit log for querying." "Spring MVC REST Controller" "Component"
                reservationEventConsumer = component "ReservationEventConsumer" "Consumes ReservationApproved events to create temporary access permissions." "Spring AMQP Consumer" "Component"
                paymentEventConsumer = component "PaymentEventConsumer" "Consumes ResidentMarkedDelinquent events to suspend access credentials." "Spring AMQP Consumer" "Component"
                accessCredentialCommandService = component "AccessCredentialCommandService" "Handles credential issuance, suspension, and revocation." "Application Service" "Component"
                qrTokenCommandService = component "QrTokenCommandService" "Issues single-use QR tokens with a TTL." "Application Service" "Component"
                accessQueryService = component "AccessQueryService" "Resolves credential, permission, and audit-log queries." "Application Service" "Component"
                accessDecisionService = component "AccessDecisionService" "Domain service: grants access only if the credential is active, the resident is not delinquent, and a valid permission exists for that area at that instant." "Domain Service" "Domain Service Component"
                accessRepository = component "AccessRepository" "Persists the AccessCredential, AccessPermission, and AccessAttempt aggregates." "Spring Data JPA Repository" "Repository Component"
                edgeGatewaySyncClient = component "EdgeGatewaySyncClient" "Pushes active credentials, active reservations, and the blacklist to the on-premise Edge API." "REST Client" "Integration Component"
                accessEventPublisher = component "AccessEventPublisher" "Publishes PhysicalAccessGranted and PhysicalAccessDenied events." "AMQP/MQTT Publisher" "Event Publisher Component"
            }
            lightingService = container "Smart Lighting & Automation Service" "Controls common area luminaires based on presence detection, ambient lux levels, reservation schedules, and manual override." "Spring Boot / Spring Data JPA / Java" "IoT Microservice" {
                automationRuleController = component "AutomationRuleController" "CRUD of automation rules by the administrator." "Spring MVC REST Controller" "Component"
                lightingOverrideController = component "LightingOverrideController" "Manual on/off override from the resident or administrator application." "Spring MVC REST Controller" "Component"
                luminaireController = component "LuminaireController" "Registers and queries luminaires and their state." "Spring MVC REST Controller" "Component"
                presenceEventConsumer = component "PresenceEventConsumer" "Consumes AreaPresenceDetected and ReservationStarted events." "Spring AMQP Consumer" "Component"
                automationRuleCommandService = component "AutomationRuleCommandService" "Creates and updates automation rules." "Application Service" "Component"
                overrideCommandService = component "OverrideCommandService" "Applies a manual override and schedules its expiration." "Application Service" "Component"
                lightingQueryService = component "LightingQueryService" "Resolves luminaire and rule state queries." "Application Service" "Component"
                automationDecisionService = component "AutomationDecisionService" "Domain service: resolves each luminaire's target state combining presence, ambient lux, reservation schedule, and active override, applying rule precedence." "Domain Service" "Domain Service Component"
                lightingRepository = component "LightingRepository" "Persists the AutomationRule, Luminaire, and OverrideCommand aggregates." "Spring Data JPA Repository" "Repository Component"
                edgeCommandPublisher = component "EdgeCommandPublisher" "Sends scheduling rules and manual override commands to the on-premise Edge API." "REST/MQTT Client" "Integration Component"
                lightingEventPublisher = component "LightingEventPublisher" "Publishes LuminaireTurnedOn, LuminaireTurnedOff, and OverrideTriggered events." "AMQP/MQTT Publisher" "Event Publisher Component"
            }
            telemetryService = container "IoT Telemetry & Analytics Service" "Ingests sensor telemetry, performs quantitative energy calculations (kWh), computes statistics, and flags hardware anomalies." "Spring Boot / Spring Data JPA / Java" "IoT Microservice" {
                telemetryQueryController = component "TelemetryQueryController" "Serves the time-series and aggregates that feed the Web Application dashboards." "Spring MVC REST Controller" "Component"
                energyReportController = component "EnergyReportController" "Serves energy consumption by area and by period." "Spring MVC REST Controller" "Component"
                anomalyController = component "AnomalyController" "Serves detected anomalies for querying." "Spring MVC REST Controller" "Component"
                telemetryIngestionConsumer = component "TelemetryIngestionConsumer" "Subscribes via MQTT to the raw readings forwarded by the Edge API." "MQTT Consumer" "Component"
                telemetryIngestionService = component "TelemetryIngestionService" "Validates, normalizes, and persists each incoming reading." "Application Service" "Component"
                energyCalculationCommandService = component "EnergyCalculationCommandService" "Recalculates the energy consumption of the affected time bucket." "Application Service" "Component"
                baselineRecalculationService = component "BaselineRecalculationService" "Updates the moving mean and standard deviation of the consumption baseline." "Application Service" "Component"
                anomalyDetectionHandler = component "AnomalyDetectionHandler" "Evaluates each new aggregation against the baseline." "Application Service" "Component"
                telemetryQueryService = component "TelemetryQueryService" "Resolves the dashboard queries." "Application Service" "Component"
                energyCalculationService = component "EnergyCalculationService" "Domain service: computes energy consumption by temporal integration of instantaneous power (kWh = Σ(V × I × Δt) / 1000)." "Domain Service" "Domain Service Component"
                anomalyDetectionService = component "AnomalyDetectionService" "Domain service: compares a sample against its baseline and distinguishes abnormal consumption from a luminaire failure." "Domain Service" "Domain Service Component"
                telemetryRepository = component "TelemetryRepository" "Persists sensor readings, energy consumption, and baselines on TimescaleDB hypertables." "Spring Data JPA Repository" "Repository Component"
                telemetryEventPublisher = component "TelemetryEventPublisher" "Publishes AbnormalConsumptionDetected and LuminaireFailureDetected events." "AMQP/MQTT Publisher" "Event Publisher Component"
            }

            // Broker de Mensajería y Bases de Datos
            messageBroker = container "Message & Event Broker" "Receives and distributes asynchronous domain events (AMQP/MQTT) such as payments, reservations, sensor telemetry, and actuator commands." "EMQX / RabbitMQ" "Message Broker"
            database = container "PostgreSQL Database" "Stores users, buildings, units, debts, payments, reservations, announcements, forum posts, notifications, and access credentials." "PostgreSQL / Relational Database" "Database"
            telemetryDatabase = container "Telemetry Database" "Stores high-frequency sensor readings, presence logs, power consumption metrics, and environmental series." "TimescaleDB / PostgreSQL" "Database"

            // Nivel Edge Computing (Instalado en Condominio)
            edgeGateway = container "Edge API & Gateway Controller" "On-premise edge gateway running on-site. Provides offline credential caching, local device coordination, and resilient operation during internet outages." "Flask / Peewee ORM / SQLite / Python" "Edge Gateway"

            // Dispositivos Fisicos Embebidos (IoT Devices)
            accessDevice = container "Common Area Access Controller" "Physical IoT embedded device with RFID reader (RC522), QR scanner, magnetic door sensor, buzzer, and electric lock relay." "ESP32 / Embedded C++" "IoT Device"
            lightingDevice = container "Smart Lighting & Sensing Node" "Physical IoT embedded node equipped with PIR presence sensor, LDR lux sensor, ACS712 current sensor, and luminaire relay." "ESP32 / Embedded C++" "IoT Device"
        }

        // ==========================================
        // Relaciones: Visitante -> Landing Page -> Frontend
        // ==========================================
        visitor -> landingPage "Browses business model information, target-segment content, and pricing"
        landingPage -> webApp "Redirects visitor via call-to-action to the corresponding Web Application sign-up/login view" "HTTP Redirect"
        landingPage -> mobileApp "Redirects visitor via call-to-action to the mobile app store listing" "HTTP Redirect / Deep Link"

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
        reservationService -> messageBroker "Publishes ReservationCreated, ReservationCancelled, ReservationApproved, and ReservationStarted events (the latter raised by an internal scheduler that polls for reservations whose time window just began)" "AMQP"
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
        edgeGateway -> messageBroker "Forwards offline access audit logs and buffered sensor telemetry, and relays AreaPresenceDetected events from lighting nodes for low-latency automation" "MQTT/AMQP WAN"
        lightingService -> edgeGateway "Sends automated scheduling rules and manual override commands" "MQTT/REST"

        // ==========================================
        // Componentes: IoT Access Management Service
        // ==========================================
        apiGateway -> accessCredentialController "Redirects credential requests" "HTTPS/REST"
        apiGateway -> qrAccessController "Redirects QR generation requests" "HTTPS/REST"
        apiGateway -> doorControlController "Redirects remote door-open requests" "HTTPS/REST"
        apiGateway -> accessAuditController "Redirects audit-log queries" "HTTPS/REST"
        accessCredentialController -> accessCredentialCommandService "Delegates credential commands"
        qrAccessController -> qrTokenCommandService "Delegates QR token issuance"
        doorControlController -> accessDecisionService "Requests a manual access decision"
        accessAuditController -> accessQueryService "Delegates audit-log queries"
        reservationEventConsumer -> accessCredentialCommandService "Triggers permission creation on ReservationApproved"
        paymentEventConsumer -> accessCredentialCommandService "Triggers credential suspension on ResidentMarkedDelinquent"
        accessCredentialCommandService -> accessDecisionService "Applies the access-granting business rule"
        accessCredentialCommandService -> accessRepository "Reads and writes credentials and permissions"
        accessCredentialCommandService -> edgeGatewaySyncClient "Triggers synchronization after a credential or permission change"
        qrTokenCommandService -> accessRepository "Persists issued QR tokens"
        accessQueryService -> accessRepository "Reads credentials, permissions, and the audit log"
        accessDecisionService -> accessRepository "Reads credential, permission, and delinquency state"
        accessDecisionService -> accessEventPublisher "Publishes the access decision outcome"
        accessRepository -> database "Reads and writes access credentials, permissions, and audit logs" "JDBC/SQL"
        accessEventPublisher -> messageBroker "Publishes PhysicalAccessGranted / PhysicalAccessDenied" "AMQP/MQTT"
        messageBroker -> reservationEventConsumer "Delivers ReservationApproved" "AMQP"
        messageBroker -> paymentEventConsumer "Delivers ResidentMarkedDelinquent" "AMQP"
        edgeGatewaySyncClient -> edgeGateway "Synchronizes credentials, reservations, and blacklist" "HTTPS/REST Sync"

        // ==========================================
        // Componentes: Smart Lighting & Automation Service
        // ==========================================
        apiGateway -> automationRuleController "Redirects automation-rule requests" "HTTPS/REST"
        apiGateway -> lightingOverrideController "Redirects manual override requests" "HTTPS/REST"
        apiGateway -> luminaireController "Redirects luminaire registration/query requests" "HTTPS/REST"
        automationRuleController -> automationRuleCommandService "Delegates rule creation/update"
        lightingOverrideController -> overrideCommandService "Delegates the manual override"
        luminaireController -> lightingQueryService "Delegates luminaire queries"
        presenceEventConsumer -> automationDecisionService "Feeds presence/reservation-start signals into the decision"
        automationRuleCommandService -> lightingRepository "Reads and writes automation rules"
        overrideCommandService -> automationDecisionService "Registers the active override for precedence"
        overrideCommandService -> lightingRepository "Persists the override and its expiration"
        lightingQueryService -> lightingRepository "Reads luminaires and rule state"
        automationDecisionService -> lightingRepository "Reads rules, luminaire state, and active overrides"
        automationDecisionService -> edgeCommandPublisher "Pushes the resolved scheduling rules and override commands"
        automationDecisionService -> lightingEventPublisher "Publishes the resulting luminaire state change"
        lightingRepository -> database "Reads and writes lighting policies, schedules, and device configs" "JDBC/SQL"
        lightingEventPublisher -> messageBroker "Publishes LuminaireTurnedOn / LuminaireTurnedOff / OverrideTriggered" "AMQP/MQTT"
        messageBroker -> presenceEventConsumer "Delivers AreaPresenceDetected and ReservationStarted" "AMQP/MQTT"
        edgeCommandPublisher -> edgeGateway "Sends scheduling rules and manual override commands" "MQTT/REST"

        // ==========================================
        // Componentes: IoT Telemetry & Analytics Service
        // ==========================================
        apiGateway -> telemetryQueryController "Redirects telemetry dashboard queries" "HTTPS/REST"
        apiGateway -> energyReportController "Redirects energy report requests" "HTTPS/REST"
        apiGateway -> anomalyController "Redirects anomaly queries" "HTTPS/REST"
        telemetryQueryController -> telemetryQueryService "Delegates dashboard queries"
        energyReportController -> telemetryQueryService "Delegates energy report queries"
        anomalyController -> telemetryQueryService "Delegates anomaly queries"
        telemetryIngestionConsumer -> telemetryIngestionService "Forwards each raw reading for validation and persistence"
        telemetryIngestionService -> telemetryRepository "Persists the normalized sensor reading"
        telemetryIngestionService -> energyCalculationCommandService "Triggers recalculation of the affected time bucket"
        energyCalculationCommandService -> energyCalculationService "Applies the temporal-integration calculation"
        energyCalculationService -> telemetryRepository "Reads readings and writes the recalculated consumption"
        energyCalculationCommandService -> baselineRecalculationService "Triggers baseline update after a new aggregation"
        baselineRecalculationService -> telemetryRepository "Reads and updates the moving mean/standard deviation baseline"
        baselineRecalculationService -> anomalyDetectionHandler "Requests anomaly evaluation against the updated baseline"
        anomalyDetectionHandler -> anomalyDetectionService "Applies the anomaly/luminaire-failure detection rule"
        anomalyDetectionService -> telemetryRepository "Reads the baseline and writes an AnomalyFlag when triggered"
        anomalyDetectionService -> telemetryEventPublisher "Publishes AbnormalConsumptionDetected / LuminaireFailureDetected"
        telemetryQueryService -> telemetryRepository "Reads readings, consumption, and anomalies for dashboards and reports"
        telemetryRepository -> telemetryDatabase "Writes high-frequency telemetry samples and queries statistical aggregations" "JDBC/SQL"
        telemetryEventPublisher -> messageBroker "Publishes AbnormalConsumptionDetected / LuminaireFailureDetected" "AMQP/MQTT"
        messageBroker -> telemetryIngestionConsumer "Delivers raw sensor readings and power telemetry" "MQTT"

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

        // ==========================================
        // Deployment Environment
        // ==========================================
        deploymentEnvironment "Production" {
            deploymentNode "Client Devices" "Devices owned by visitors, administrators, and residents" "End-user hardware" {
                deploymentNode "Web Browser" "Chrome, Edge, Safari, or Firefox" "Desktop / Mobile Browser" {
                    containerInstance landingPage
                    containerInstance webApp
                }
                deploymentNode "Mobile Device" "iOS or Android smartphone" "Mobile OS" {
                    containerInstance mobileApp
                }
            }

            deploymentNode "Render" "Cloud PaaS hosting the stateless backend services" "Render.com" {
                deploymentNode "API Gateway Node" "Web Service instance" "Render Web Service" {
                    containerInstance apiGateway
                }
                deploymentNode "Core Microservices Cluster" "Web Service instances" "Render Web Services" {
                    containerInstance iamService
                    containerInstance residentialService
                    containerInstance paymentService
                    containerInstance reservationService
                    containerInstance communicationService
                    containerInstance forumService
                    containerInstance notificationService
                    containerInstance reportService
                }
                deploymentNode "IoT Cloud Microservices Cluster" "Web Service instances" "Render Web Services" {
                    containerInstance accessService
                    containerInstance lightingService
                    containerInstance telemetryService
                }
            }

            deploymentNode "Supabase" "Managed PostgreSQL cloud provider" "Supabase" {
                deploymentNode "PostgreSQL Instance" "Relational data for classic and IoT microservices" "PostgreSQL 15" {
                    containerInstance database
                }
                deploymentNode "TimescaleDB Instance" "Time-series extension for telemetry data" "PostgreSQL 15 + TimescaleDB" {
                    containerInstance telemetryDatabase
                }
            }

            deploymentNode "Message Broker Cloud" "Managed AMQP/MQTT broker" "CloudAMQP / EMQX Cloud" {
                containerInstance messageBroker
            }

            deploymentNode "Condominium Site" "On-premise installation at each building" "Physical Location" {
                deploymentNode "Edge Server" "Local gateway hardware, resilient to WAN outages" "Raspberry Pi 4 / Mini PC" {
                    containerInstance edgeGateway
                }
                deploymentNode "Common Area Door Unit" "Installed at each common area door" "Embedded Hardware" {
                    containerInstance accessDevice
                }
                deploymentNode "Common Area Lighting Unit" "Installed at each luminaire" "Embedded Hardware" {
                    containerInstance lightingDevice
                }
            }
        }
    }

    views {
        systemLandscape "SystemLandscape" {
            include *
            autoLayout lr
        }

        systemContext edifika "SystemContext" {
            include *
            autoLayout lr
        }

        container edifika "Containers" {
            include *
            autoLayout lr
        }

        deployment edifika "Production" "Deployment" {
            include *
            autoLayout lr
        }

        component accessService "ComponentsAccessService" {
            include *
            autoLayout lr
        }

        component lightingService "ComponentsLightingService" {
            include *
            autoLayout lr
        }

        component telemetryService "ComponentsTelemetryService" {
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

            // Landing Page
            element "Landing Page" {
                shape WebBrowser
                background #f59e0b
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

            // Componentes (nivel Component Diagram de los microservicios IoT)
            element "Component" {
                shape Component
                background #f2b705
                color #1c1500
                stroke #a37804
                strokeWidth 1
            }
            element "Domain Service Component" {
                shape Component
                background #f2b705
                color #1c1500
                stroke #7f1d1d
                strokeWidth 3
            }
            element "Repository Component" {
                shape Cylinder
                background #f2b705
                color #1c1500
                stroke #a37804
                strokeWidth 1
            }
            element "Integration Component" {
                shape Pipe
                background #f2b705
                color #1c1500
                stroke #a37804
                strokeWidth 1
            }
            element "Event Publisher Component" {
                shape Pipe
                background #f2b705
                color #1c1500
                stroke #a37804
                strokeWidth 1
            }
        }
    }
}
