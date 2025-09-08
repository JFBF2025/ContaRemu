import { Body, Controller, Post } from '@nestjs/common';
import { CompaniesService } from './companies.service';

@Controller('companies')
export class CompaniesController {
  constructor(private readonly svc: CompaniesService) {}
  @Post()
  create(@Body() body: any) { return this.svc.create(body); }
}