import 'dotenv/config';
import { DataSource } from 'typeorm';

const hasUrl = !!process.env.DATABASE_URL;
export const AppDataSource = new DataSource({
  type: 'postgres',
  url: hasUrl ? process.env.DATABASE_URL : undefined,
  host: hasUrl ? undefined : process.env.DB_HOST,
  port: hasUrl ? undefined : Number(process.env.DB_PORT || 5432),
  username: hasUrl ? undefined : process.env.DB_USER,
  password: hasUrl ? undefined : process.env.DB_PASS,
  database: hasUrl ? undefined : process.env.DB_NAME,
  synchronize: false,
  logging: false,
  entities: [__dirname + '/src/**/*.entity.{ts,js}'],
});