import { Body, Controller, Post } from '@nestjs/common';
import { AppDataSource } from '../../../ormconfig';
@Controller('contracts')
export class ContractsController {
  @Post()
  async create(@Body() b: any) {
    const ds = await AppDataSource.initialize();
    const sql = `INSERT INTO contract(id,employee_id,start_date,type,jornada,base_salary,gratification_regimen)
      VALUES(uuid_generate_v4(),$1,$2,$3,$4,$5,$6) RETURNING id`;
    const res = await ds.query(sql,[b.employee_id,b.start_date,b.type,b.jornada,b.base_salary,b.gratification_regimen||'ART50']);
    await ds.destroy();
    return { id: res[0].id };
  }
}
