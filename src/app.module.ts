import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppDataSource } from '../ormconfig';
import { CompaniesModule } from './companies/companies.module';
import { EmployeesModule } from './employees/employees.module';
import { ContractsModule } from './contracts/contracts.module';
import { PayrunsModule } from './payruns/payruns.module';
import { ExportsModule } from './exports/exports.module';
import { AdminModule } from './admin/admin.module';

@Module({
  imports: [
    TypeOrmModule.forRoot(AppDataSource.options as any),
    CompaniesModule,
    EmployeesModule,
    ContractsModule,
    PayrunsModule,
    ExportsModule,
    AdminModule,
  ],
})
export class AppModule {}
