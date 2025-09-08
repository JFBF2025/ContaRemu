CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS company (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rut VARCHAR(12) NOT NULL UNIQUE,
  legal_name TEXT NOT NULL,
  fantasy_name TEXT,
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cost_center (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES company(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  UNIQUE(company_id, code)
);

CREATE TABLE IF NOT EXISTS indicators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  period DATE NOT NULL,
  uf NUMERIC(14,5) NOT NULL,
  utm NUMERIC(14,2) NOT NULL,
  imponible_tope_afp NUMERIC(14,2) NOT NULL,
  imponible_tope_salud NUMERIC(14,2) NOT NULL,
  UNIQUE(period)
);

DO $$ BEGIN
  CREATE TYPE contract_type AS ENUM ('INDEFINIDO','PLAZO_FIJO','FAENA');
EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN
  CREATE TYPE jornada_type AS ENUM ('COMPLETA','PARCIAL','ART22');
EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN
  CREATE TYPE grat_regimen AS ENUM ('ART47','ART50');
EXCEPTION WHEN duplicate_object THEN null; END $$;

CREATE TABLE IF NOT EXISTS employee (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES company(id) ON DELETE CASCADE,
  rut VARCHAR(12) NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  birth_date DATE,
  address TEXT,
  afp_code TEXT,
  salud_code TEXT,
  mutual_code TEXT,
  afc_affiliated BOOLEAN DEFAULT TRUE,
  UNIQUE(company_id, rut)
);

CREATE TABLE IF NOT EXISTS contract (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employee(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE,
  type contract_type NOT NULL,
  jornada jornada_type NOT NULL,
  base_salary NUMERIC(14,2) NOT NULL,
  gratification_regimen grat_regimen NOT NULL DEFAULT 'ART50',
  cost_center_id UUID REFERENCES cost_center(id),
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

DO $$ BEGIN
  CREATE TYPE item_kind AS ENUM ('EARNING','DEDUCTION','CONTRIBUTION');
EXCEPTION WHEN duplicate_object THEN null; END $$;

CREATE TABLE IF NOT EXISTS pay_item_type (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  kind item_kind NOT NULL,
  taxable BOOLEAN NOT NULL DEFAULT TRUE,
  pensionable BOOLEAN NOT NULL DEFAULT TRUE,
  healthable BOOLEAN NOT NULL DEFAULT TRUE,
  formula JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DO $$ BEGIN
  CREATE TYPE payrun_status AS ENUM ('DRAFT','CALCULATED','APPROVED','POSTED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

CREATE TABLE IF NOT EXISTS payrun (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES company(id) ON DELETE CASCADE,
  period DATE NOT NULL,
  status payrun_status NOT NULL DEFAULT 'DRAFT',
  indicators_id UUID NOT NULL REFERENCES indicators(id),
  UNIQUE(company_id, period)
);

CREATE TABLE IF NOT EXISTS payslip (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payrun_id UUID NOT NULL REFERENCES payrun(id) ON DELETE CASCADE,
  contract_id UUID NOT NULL REFERENCES contract(id),
  employee_id UUID NOT NULL REFERENCES employee(id),
  days_worked NUMERIC(5,2) DEFAULT 30,
  taxable_base NUMERIC(14,2) DEFAULT 0,
  pensionable_base NUMERIC(14,2) DEFAULT 0,
  health_base NUMERIC(14,2) DEFAULT 0,
  gross_pay NUMERIC(14,2) DEFAULT 0,
  net_pay NUMERIC(14,2) DEFAULT 0,
  UNIQUE(payrun_id, employee_id)
);

CREATE TABLE IF NOT EXISTS payslip_item (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payslip_id UUID NOT NULL REFERENCES payslip(id) ON DELETE CASCADE,
  item_type_id UUID NOT NULL REFERENCES pay_item_type(id),
  amount NUMERIC(14,2) NOT NULL,
  metadata JSONB,
  position SMALLINT NOT NULL DEFAULT 0
);

DO $$ BEGIN
  CREATE TYPE account_type AS ENUM ('ASSET','LIABILITY','EQUITY','REVENUE','EXPENSE');
EXCEPTION WHEN duplicate_object THEN null; END $$;

CREATE TABLE IF NOT EXISTS account (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES company(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  type account_type NOT NULL,
  allow_post BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE(company_id, code)
);

CREATE TABLE IF NOT EXISTS journal (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES company(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  UNIQUE(company_id, code)
);

DO $$ BEGIN
  CREATE TYPE move_state AS ENUM ('DRAFT','POSTED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

CREATE TABLE IF NOT EXISTS journal_entry (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  journal_id UUID NOT NULL REFERENCES journal(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  ref TEXT,
  state move_state NOT NULL DEFAULT 'POSTED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS journal_line (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entry_id UUID NOT NULL REFERENCES journal_entry(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES account(id),
  description TEXT,
  debit NUMERIC(14,2) NOT NULL DEFAULT 0,
  credit NUMERIC(14,2) NOT NULL DEFAULT 0,
  cost_center_id UUID REFERENCES cost_center(id)
);

CREATE TABLE IF NOT EXISTS lre_submission (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payrun_id UUID NOT NULL REFERENCES payrun(id) ON DELETE CASCADE,
  sent_at TIMESTAMPTZ,
  status TEXT,
  response JSONB
);

CREATE TABLE IF NOT EXISTS previ_file (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payrun_id UUID NOT NULL REFERENCES payrun(id) ON DELETE CASCADE,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  format TEXT NOT NULL DEFAULT 'CSV',
  content TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dj1887 (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES company(id) ON DELETE CASCADE,
  year INT NOT NULL,
  payload JSONB NOT NULL,
  submitted_at TIMESTAMPTZ,
  status TEXT,
  UNIQUE(company_id, year)
);

CREATE OR REPLACE VIEW v_trial_balance AS
SELECT a.company_id,
       a.code AS account_code,
       a.name AS account_name,
       a.type AS account_type,
       COALESCE(SUM(jl.debit),0) AS total_debit,
       COALESCE(SUM(jl.credit),0) AS total_credit,
       COALESCE(SUM(jl.debit - jl.credit),0) AS balance
FROM account a
LEFT JOIN journal_line jl ON jl.account_id = a.id
LEFT JOIN journal_entry je ON je.id = jl.entry_id
GROUP BY a.company_id, a.code, a.name, a.type;