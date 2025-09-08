# ContaRemu (MVP)

Backend NestJS + PostgreSQL para remuneraciones y contabilidad (Chile).

## Correr local (opcional)
1) Instala Docker Desktop y PNPM
2) `docker compose up -d`
3) `pnpm i`
4) `cp .env.example .env` (ajusta si quieres)
5) `pnpm migration:run && pnpm seed`
6) `pnpm start:dev` → `http://localhost:3000/api`

## Despliegue gratuito en Render
1) Crea cuenta en https://render.com e **importa** este repo desde GitHub.
2) Crea un servicio **PostgreSQL** (gratis). Copia el `External Database URL`.
3) En el servicio Web (Node) configura las variables de entorno:
   - `DATABASE_URL` = la URL de Postgres de tu instancia Render
   - `PORT` = 10000 (Render puede ignorarlo, pero es útil)
   - `INIT_TOKEN` = un valor secreto que inventes (ej: `contaremu-123`)
4) **Build Command**: `pnpm i && pnpm build`
5) **Start Command**: `node dist/main.js`
6) Una vez deployado, ejecuta la inicialización (una sola vez):
   - `GET https://TU-SERVICIO.onrender.com/api/admin/migrate` con header `x-init-token: TU_INIT_TOKEN`
   - Respuesta esperada: `{ ok: true, message: 'Schema + seed ejecutados' }`

## Endpoints básicos
- `POST /api/companies` → crea empresa `{ rut, legal_name, fantasy_name }`
- `POST /api/employees` → crea trabajador `{ company_id, rut, first_name, last_name, afp_code?, salud_code? }`
- `POST /api/contracts` → crea contrato `{ employee_id, start_date, type, jornada, base_salary, gratification_regimen? }`
- `POST /api/payruns/:period/compute` → inicia cálculo (stub) `{ company_id }` (period = YYYY-MM)
- `POST /api/exports/previ/:period` → genera CSV base PreviRed
- `POST /api/exports/lre/:period` → genera payload LRE (stub)

> Nota: este MVP crea la estructura y stubs. En siguientes iteraciones añadiremos motor de cálculo real, validadores, y contabilidad automática.