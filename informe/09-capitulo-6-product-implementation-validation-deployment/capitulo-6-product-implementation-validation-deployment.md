# Capítulo VI: Product Implementation, Validation & Deployment

> 📋 **Guía (Statement):** En esta sección el equipo explica y evidencia el proceso de implementar, comprobar, desplegar y validar la solución compuesta en este caso por los productos digitales que forman parte del alcance. El Landing Page permite presentar el modelo de negocio y las aplicaciones web. Los procesos del negocio digital que dirigen la operación del negocio, tanto procesos core del negocio como procesos de soporte (por ejemplo Authentication & Authorization, Subscriptions, entre otros) están distribuidos entre los productos digitales que forman parte del alcance como por ejemplo RESTful Web Services, Native Mobile Applications, Web Applications, Edge Web Services, Embedded Applications u otros. Este capítulo abarca secciones para la organización del proceso de trabajo en Sprints, la descripción y prácticas asociadas a Software Configuration Management, las evidencias de Implementation, Testing, Despliegue y Validaciones para cada uno de los productos que forman parte de la solución, en términos del producto en sí y la colaboración por Sprint.

**Estado:** ⬜ Pendiente

## 6.1. Software Configuration Management

> 📋 **Guía (Statement):** En esta sección el equipo establece las decisiones y convenciones que permitirán mantener la consistencia durante el ciclo de vida. Se incluyen secciones internas para Source Code Management, Development Environment Configuration y Deployment Configuration.

### 6.1.1. Software Development Environment Configuration

> 📋 **Guía (Statement):** En esta sección el equipo específica, describe e indica los nombres de productos, el propósito de uso en el proyecto, la ruta de referencia (para software basado en modelos SaaS) o ruta de descarga (para productos que se ejecutan en el computador del miembro del equipo) de cada uno de los productos de software que deben utilizar los miembros del equipo para colaborar en el ciclo de vida de los productos digitales que forman la solución con IoT, considerando todos los tipos de actividades como Project Management, Requirements Management, Product UX/UI Design, Software Development, Software Testing, Software Deployment, Software Documentation, respetando las restricciones indicadas sobre productos de software y herramientas que se pueden utilizar.

| Actividad | Producto/Herramienta | Propósito de uso | Ruta de referencia/descarga |
|---|---|---|---|
| | | | |

### 6.1.2. Source Code Management

> 📋 **Guía (Statement):** En esta sección el equipo establece los medios y esquema de organización que aplicará para el seguimiento de modificaciones. Para ello utilizará GitHub como plataforma y sistema de control de versiones. Debe incluirse el URL del repositorio de GitHub para cada producto: Landing Page, Web Services, Frontend Web Applications. Tomar en cuenta que en el caso de Web Services, se incluye en el repositorio el proyecto y los archivos de pruebas, tanto unitarias como de integración/aceptación.
>
> En esta sección debe también explicarse de qué forma implementará GitFlow como Workflow de control de versiones, es decir qué branches (ramas) creará además de main branch (rama principal), por ejemplo, develop branch. Para GitFlow cada Feature requiere su propio branch, por ello debe especificar qué convenciones se aplicará para nombrar los feature branches. Igualmente debe incluir las convenciones para Release branches y Hotfix branches. Aplique semantic versioning para nombrar sus Releases.
>
> Aplique Conventional Commits para los textos de mensajes en sus commits.

| Producto | URL del repositorio |
|---|---|
| Landing Page | |
| Web Services | |
| Frontend Web Applications | |

_(Explicación de GitFlow: naming de feature/release/hotfix branches, Semantic Versioning, Conventional Commits)_

### 6.1.3. Source Code Style Guide & Conventions

> 📋 **Guía (Statement):** Aquí el equipo explica e indica las referencias que adoptará para nombrar elementos y programar en los lenguajes que se utilizan en la solución (HTML, CSS, JavaScript, TypeScript, Java, C#, Kotlin, Swift, C++, Python u otros según los constraints del proyecto; así como Gherkin para los archivos .feature). Para todos los lenguajes debe aplicar la nomenclatura en inglés. Adicionalmente, adopte convenciones estándares para coding (por ejemplo HTML Style Guide and Coding Conventions, Google HTML/CSS Style Guide, Gherkin Conventions for Readable Specifications, Angular coding style guide, Google Java Style Guide, Google TypeScript Style Guide y Spring Boot Features).

| Lenguaje/Tecnología | Style Guide adoptado |
|---|---|
| | |

### 6.1.4. Software Deployment Configuration

> 📋 **Guía (Statement):** En esta sección el equipo especifica la configuración del despliegue de la solución, incluyendo los pasos necesarios para que, a partir de los repositorios de código fuente, se pueda lograr el despliegue o publicación satisfactorio de cada uno de los productos digitales en la solución (Landing Page, Web Services, Web Applications, Mobile Applications, Embedded Applications u otros productos incluidos). Adicionalmente a la explicación, el equipo incluye aquí el Deployment Diagram de C4 Model.

## 6.2. Landing Page, Services & Applications Implementation

> 📋 **Guía (Statement):** En esta sección se explica y evidencia el proceso de implementación, pruebas, documentación y despliegue del Landing Page, Web Services, Web Applications, Mobile Applications y Embedded Applications. En esta sección se incluye, una vez que se cuenta con el Product Backlog, una sección interna cada Sprint (Sprint 1, Sprint 2, etc.).
>
> ⚠️ Duplicar la sub-sección `6.2.X. Sprint n` a continuación por cada Sprint del proyecto (6.2.1 Sprint 1, 6.2.2 Sprint 2, 6.2.3 Sprint 3, ...).

### 6.2.X. Sprint n

> 📋 **Guía (Statement):** En esta sección se registra y explica el avance en términos de producto y trabajo colaborativo para el Sprint n. Incluye como secciones internas: *Sprint Planning n*, *Aspect Leaders and Collaborators*, *Sprint Backlog n*, *Development Evidence for Sprint Review*, *Testing Suite Evidence for Sprint Review*, *Execution Evidence for Sprint Review*, *Services Documentation Evidence for Sprint Review*, *Software Deployment Evidence for Sprint Review*, junto con *Team Collaboration Insights during Sprint*.

#### 6.2.X.1. Sprint Planning n

> 📋 **Guía (Statement):** En esta sección se especifica los aspectos principales del Sprint Planning Meeting. Se inicia la sección con una introducción y a continuación se coloca el cuadro de resumen del sprint planning meeting.

| Sprint # | Sprint n |
|---|---|
| Sprint Planning | Background |
| Date | YYYY-MM-DD |
| Time | HH:MM AM/PM |
| Location | _(Descripción de la ubicación de la reunión, física o virtual)_ |
| Prepared By | |
| Sprint n – Review | _(resultados alcanzados a nivel de productos de la solución)_ |
| Sprint n – Retrospective | _(oportunidades de mejora en la forma de trabajo)_ |
| Sprint n Goal | _(Definir el Goal del Sprint n y la métrica de éxito)_ |
| Sprint n Velocity | _(Definir el Velocity establecido para el Sprint n)_ |
| Sum of Story Points | _(Suma de los Story Points para los User Stories del Sprint)_ |

> 📋 **Guía (Statement) — Sprint Goal:** Es muy importante que el equipo dedique atención a la identificación del Sprint Goal. Según el Scrum Guide "El Sprint Goal es el objetivo individual del Sprint. Es un compromiso para los Developers, flexible en términos del trabajo exacto que se requiere para alcanzarlo. El Sprint Goal también crea coherencia y enfoque, buscando que los miembros del Scrum Team trabajen juntos en vez de ir en pos de iniciativas individuales."
>
> Para identificar el Sprint Goal, es recomendable enfocarse en el negocio (business) o la perspectiva de los usuarios (user-focused), como por ejemplo entregar un nuevo feature o feature set. Escribir objetivos SMART (Specific, Measurable, Attainable, Relevant, Time-bound) puede ser de mucha utilidad.
>
> Scrum.org ofrece un template para redactar Sprint Goals:
>
> *Our focus is on* `<Outcome>`
>
> *We believe it delivers* `<Impact>` to `<Customer(s)>`
>
> *This will be confirmed when* `<Event happens>`
>
> Es recomendable que la redacción sea específica en términos de qué features se compromete a lograr y cómo benefician a los segmentos objetivo, sin detallar cómo (p.ej. "A customer can place an order from a single-product catalog", "Show a multi-product catalog", "Show top-selling products").
>
> Es muy importante que el equipo establezca en conjunto el Sprint Goal, pues de esa forma todo el equipo puede trabajar en identificar qué epics y stories deberían considerarse en principio en la iteración, en base a su contribución para ese Goal en particular.

**Sprint Goal:**

_(pendiente — aplicar template Our focus / We believe / This will be confirmed when)_

#### 6.2.X.2. Aspect Leaders and Collaborators

> 📋 **Guía (Statement):** En esta sección el equipo incluye la elaboración de un artefacto Leadership-and-Collaboration Matrix (LACX), que indique por cada aspecto dentro del alcance del Sprint, quién es el líder y quién o quiénes son colaboradores en dicho aspecto, con el fin de brindar mayor claridad y efectividad en la comunicación al interior del equipo. La sección incluye una introducción donde se explica cuáles son los principales aspectos que se toma en cuenta en el Sprint. Dependiendo del Sprint un aspecto puede ser un subconjunto del alcance funcional de la solución (por ejemplo feature, bounded context, etc.). La organización de líderes y colaboradores debe tener relación con la posterior selección de tasks en el Sprint.

| GitHub Username | Aspect Name 1 | Aspect Name 2 | Aspect Name 3 |
|---|---|---|---|
| | | | |

_(L = Leader, C = Collaborator)_

#### 6.2.X.3. Sprint Backlog n

> 📋 **Guía (Statement):** Una sección de Sprint Backlog debe iniciar con una introducción que resuma el objetivo principal del Sprint y a continuación presente un screenshot del Board para el Sprint en la herramienta de control indicada (por ejemplo Trello), junto con el URL público del Board. A continuación, debe incluir una tabla donde se especifique los User Stories asignados al Sprint, junto con los Work-items/Tasks resultantes de la descomposición de los User Stories o Tasks adicionales que no dependen de un User Story en particular (por ejemplo, un task que debe realizarse para satisfacer un constraint general).

**URL público del Board:** _(pendiente)_

| Sprint # | Sprint n | | | |
|---|---|---|---|---|
| Story Id | Story Title | Task Id | Task Title / Description | Estimation (Hours) / Assigned To |
| | | | | |

#### 6.2.X.4. Development Evidence for Sprint Review

> 📋 **Guía (Statement):** En esta sección se explica y presenta los avances en implementación con relación a los productos de la solución según el alcance del Sprint: Landing Page, Web Applications, Web Services y otros. La sección inicia con una introducción que resume los principales avances en la implementación. Debe elaborarse una tabla que incluya para cada repositorio los commits relacionados con la implementación.

| Repository | Branch | Commit Id | Commit Message | Commit Message Body | Committed on (Date) |
|---|---|---|---|---|---|
| | | | | | |

#### 6.2.X.5. Testing Suite Evidence for Sprint Review

> 📋 **Guía (Statement):** En esta sección se explica y presenta el conjunto de Unit Tests, Integration Tests y Acceptance Tests automatizados, para Web Services relacionados con los User Stories especificados en el Sprint. En el caso de los tests de BDD debe elaborarse los archivos .feature utilizando el lenguaje Gherkin y los archivos Steps en el lenguaje de programación. En esta sección se debe incluir la relación de tests diseñados. En el caso de los Unit Tests, debe indicarse con qué clases y comportamientos se relacionan. En el caso de los Integration Tests ó Acceptance Tests bajo el enfoque BDD, se incluye el código de los .feature Files, explicando con qué User Stories se relacionan. También debe incluirse la ruta del repositorio de control de versiones para los proyectos de Testing, junto con los id de commits relacionados con los avances en Testing para este Sprint.

| Repository | Branch | Commit Id | Commit Message | Commit Message Body | Committed on (Date) |
|---|---|---|---|---|---|
| | | | | | |

#### 6.2.X.6. Execution Evidence for Sprint Review

> 📋 **Guía (Statement):** Esta sección inicia con un resumen que explique lo alcanzado en este Sprint y presenta screenshots de las principales vistas implementadas, junto con un enlace a un video que ilustre y explique la visualización y navegación logrados en este Sprint.

#### 6.2.X.7. Services Documentation Evidence for Sprint Review

> 📋 **Guía (Statement):** En esta sección se incluye la relación de Endpoints documentados con OpenAPI, relacionados con el alcance del Sprint. La sección inicia con una introducción en la que se resume los logros alcanzados en relación con Documentación de Web Services para este Sprint. Debe elaborarse una tabla en la que se incluya, para cada Endpoint, la indicación de acciones implementadas, junto con los enlaces correspondientes a la documentación desplegada (o URL local en Sprints previos al despliegue de Web Services). Indicar las acciones soportadas incluyendo para cada acción el verbo http (get, post, put, delete, patch), sintaxis de llamada, especificación de posibles parámetros, así como ejemplo y explicación del response. Adicionalmente, debe incluirse y explicarse capturas en imágenes de la interacción, utilizando datos de muestra, con la documentación elaborada. Debe incluirse el URL del repositorio de Web Services, junto con los id de los commits relacionados con Documentación para este Sprint.

#### 6.2.X.8. Software Deployment Evidence for Sprint Review

> 📋 **Guía (Statement):** En esta sección se resume los procesos realizados en relación con Deployment durante este Sprint. La sección inicia con una introducción explicando qué se ha realizado con respecto a despliegue durante este Sprint. Abarca actividades de creación de cuentas, configuración de recursos en cloud providers, configuración de proyectos de desarrollo para integración o automatización de labor de Deployment, entre otros. Se considera dentro del proceso de Deployment todos los productos digitales: Landing Page, Web Services, Aplicaciones y otros productos que formen parte del alcance. Se debe adicionar capturas en imagen y explicaciones de los pasos realizados durante el Sprint.

#### 6.2.X.9. Team Collaboration Insights during Sprint

> 📋 **Guía (Statement):** En esta sección el equipo explica cómo se han desarrollado las actividades de implementación y se presenta capturas en imagen de los analíticos de colaboración y commits en GitHub, realizados por los miembros del equipo, así como la redacción de la interpretación de estos analíticos por parte del equipo. Todos los miembros del equipo deben tener participación en la implementación de cada uno de los productos según corresponda en el Sprint: Landing Page, Web Services y Aplicaciones.

## 6.3. Validation Interviews

> 📋 **Guía (Statement):** En esta sección, el equipo registra y explica las actividades de entrevistas de validación durante el proyecto. Se debe realizar entrevistas de validación en las que usuarios de los segmentos objetivo interactúen con el landing page y con las aplicaciones. Incluye secciones internas para Diseño de Entrevistas, Registro de Entrevistas, Evaluaciones según heurísticas. Para el proceso de validación debe aplicarse el formato de evaluación heurística indicado para el proyecto (ver [Anexo D](../12-anexos/anexo-d-evaluacion-ux-heuristicas.md)).

### 6.3.1. Diseño de Entrevistas

> 📋 **Guía (Statement):** En esta sección el equipo establece por cada segmento objetivo los elementos a incluir en la sesión de validación, incluyendo el Landing Page y las aplicaciones. Aquí se especifica también cuáles serán los user flows de las aplicaciones, que formarán parte del proceso de validación.

### 6.3.2. Registro de Entrevistas

> 📋 **Guía (Statement):** Para cada segmento se requiere de 3 a 5 entrevistas. Para cada una de las entrevistas se debe indicar la información de nombres, apellidos, edad, distrito, un screenshot de un cuadro de video y el URL del video subido en Microsoft Stream/Clipchamp incluyendo el timing donde inicia la entrevista y su duración. La entrevista debe ser registrada en video, que sirve de evidencia de entrevistas. Para cada entrevista debe redactarse en este informe un resumen, que explica de forma descriptiva las principales apreciaciones del entrevistado con respecto a las tareas asignadas. Ver [Anexo C. Indicaciones para secciones que incluyen Videos](../12-anexos/anexo-c-indicaciones-videos.md).

### 6.3.3. Evaluaciones según heurísticas

> 📋 **Guía (Statement):** Esta sección contiene el proceso de evaluación de las sesiones de validación basado en heurísticas, considerando heurísticas de usabilidad, arquitectura de información e inclusive design de la experiencia propuesta. Para esto la sección debe contener la estructura del formato para evaluaciones de heurísticas indicado en el [Anexo D](../12-anexos/anexo-d-evaluacion-ux-heuristicas.md).

## 6.4. Video About-the-Product

> 📋 **Guía (Statement):** En esta sección el equipo redacta una introducción y resumen del contenido incluido en el Video About-the-Product, el cual tiene como público objetivo los visitantes al Landing Page, quienes desean conocer sobre el modelo de negocio y las características principales de los productos de software, al igual que los usuarios de las Aplicaciones, quienes desean realizar tareas relacionadas con los procesos soportados por la solución. El tono que utilice en la comunicación debe ser consistente con el tono adoptado para el producto y debe incluirse al menos un testimonio positivo de un usuario que haya participado en las entrevistas de validación. Debe incluirse también en esta sección un screenshot del Video, el URL de la versión publicada en Microsoft Stream/Clipchamp (y además, el URL de la versión publicada en YouTube utilizada para incrustarse en el Landing Page), así como el timing (duración) del mismo. Ver [Anexo C](../12-anexos/anexo-c-indicaciones-videos.md).

**URL Stream/Clipchamp:** _(pendiente)_
**URL YouTube:** _(pendiente)_
**Duración:** _(pendiente)_
