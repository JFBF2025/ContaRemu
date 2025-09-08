import { Body, Controller, Post } from '@nestjs/common';
import { AppDataSource } from '../../ormconfig';
@Controller('employees')
export class EmployeesController {
  @Post()
  async create(@Body() b: any) {
    const ds = await AppDataSource.initialize();
    const sql = `INSERT INTO employee(id,company_id,rut,first_name,last_name,afp_code,salud_code)
                 VALUES(uuid_generate_v4(),$1,$2,$3,$4,$5,$6) RETURNING id`;
    const res = await ds.query(sql, [b.company_id,b.rut,b.first_name,b.last_name,b.afp_code||null,b.salud_code||null]);
    await ds.destroy();
    return { id: res[0].id };
  }
}
