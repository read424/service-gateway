# Service Gateway

API Gateway reactivo para la plataforma de microservicios bancarios.

## Descripción

Service Gateway es un API Gateway basado en Spring Cloud Gateway con WebFlux. Proporciona:

- 🚀 **Enrutamiento dinámico** - Basado en service discovery (Eureka)
- ⚡ **Reactivo** - WebFlux para alto rendimiento
- 🔐 **Autenticación** - Soporte para seguridad
- 🛡️ **Limitación de tasa** - Rate limiting
- 📊 **Monitoreo** - Métricas y health checks
- 🔄 **Balanceo de carga** - Con Eureka client-side

## Características

- Descubrimiento de servicios desde Eureka
- Enrutamiento automático (`lb://service-name`)
- Filtros por Path predicates
- Métricas de Gateway
- Health checks
- Integración con Config Server

## Configuración

### Desarrollo (application.yaml local)

Configuración local para desarrollo con Eureka y rutas básicas.

### Producción

La configuración se obtiene de **bootcamp-config-repo** vía Config Server:

- `bootcamp-config-repo/config/service-gateway/application.yaml` - Base
- `bootcamp-config-repo/config/service-gateway/application-prod.yaml` - Producción

El flujo es:
```
Service Gateway
    ↓
Config Server (http://localhost:8888)
    ↓
bootcamp-config-repo/config/service-gateway/
    ↓
application.yaml o application-prod.yaml (descifrado si necesario)
```

## Rutas disponibles

| Servicio | Path | Destino |
|----------|------|---------|
| Clientes | `/api/v1/customers/**` | ms-customer:8081 |
| Cuentas | `/api/v1/accounts/**` | ms-accounts:8082 |
| Créditos | `/api/v1/credits/**` | ms-credits:8083 |
| Transacciones | `/api/v1/transactions/**` | ms-transaction:8084 |
| Balances | `/api/v1/balances/**` | ms-balance:8085 |

## Docker

### Build
```bash
docker build -t service-gateway:latest .
```

### Run (con dependencias)
```bash
docker compose up -d
```

Esto levanta:
- service-gateway (puerto 8080)
- service-config-server (puerto 8888)
- service-eureka (puerto 8761)

### Verificar
```bash
# Health check
curl http://localhost:8080/actuator/health

# Gateway status
curl http://localhost:8080/actuator/gateway/routes

# Probar una ruta
curl http://localhost:8080/api/v1/customers/
```

## Acceso

- **API Gateway**: http://localhost:8080/
- **Health Check**: http://localhost:8080/actuator/health
- **Gateway Routes**: http://localhost:8080/actuator/gateway/routes
- **Métricas**: http://localhost:8080/actuator/metrics
- **Prometheus**: http://localhost:8080/actuator/prometheus

## Flujo de solicitud

```
Cliente HTTP
    ↓
Service Gateway (8080)
    ↓
    ├─→ lb://ms-customer → ms-customer (8081)
    ├─→ lb://ms-accounts → ms-accounts (8082)
    ├─→ lb://ms-credits → ms-credits (8083)
    └─→ lb://ms-transaction → ms-transaction (8084)
    ↓
Service Discovery (Eureka)
```

## Dependencias de inicio

El gateway requiere que estén corriendo:

1. **Config Server** (puerto 8888) - Para configuración centralizada
2. **Eureka** (puerto 8761) - Para descubrimiento de servicios
3. **Microservicios** - Registrados en Eureka

Con `docker compose up` se levantan automáticamente.

## Troubleshooting

### El gateway no encuentra los servicios
- Verificar que Eureka está corriendo: `curl http://localhost:8761/`
- Verificar que los microservicios se registraron en Eureka
- Ver logs: `docker logs service-gateway`

### Errores al conectar a Config Server
- Verificar que Config Server está corriendo en 8888
- Revisar variable `SPRING_CONFIG_IMPORT`
- Ver logs de startup del gateway

### Ruta no funciona
```bash
# Ver rutas configuradas
curl http://localhost:8080/actuator/gateway/routes | jq

# Ver rutas filtradas
curl http://localhost:8080/actuator/gateway/routes/ms-customer | jq
```

## Configuración de rutas

Agregar nueva ruta en `application.yaml`:

```yaml
spring:
  cloud:
    gateway:
      server:
        webflux:
          routes:
            - id: nuevo-servicio
              uri: lb://nuevo-servicio
              predicates:
                - Path=/api/v1/nuevo/**
              filters:
                - StripPrefix=0
```

## Documentación oficial

- [Spring Cloud Gateway](https://spring.io/projects/spring-cloud-gateway)
- [WebFlux](https://docs.spring.io/spring-framework/reference/web/webflux.html)
- [Spring Cloud Netflix Eureka](https://cloud.spring.io/spring-cloud-netflix/multi/multi__service_discovery_eureka_clients.html)
