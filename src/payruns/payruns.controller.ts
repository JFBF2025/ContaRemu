import { Body, Controller, Param, Post } from '@nestjs/common';
import { AppDataSource } from '../../../ormconfig';

@Controller('payruns')
export class PayrunsController {
  @Post(':period/compute')
  async compute(@Param('period') period: string, @Body() body: any){
    const ds = await AppDataSource.initialize();
    const [ind] = await ds.query('SELECT * FROM indicators WHERE period=$1',[period+'-01']);
    if(!ind) throw new Error('Faltan indicadores (UF/UTM/topes) para el periodo');
    const pr = await ds.query(
      `INSERT INTO payrun(id,company_id,period,status,indicators_id)
       VALUES(uuid_generate_v4(),$1,$2,'DRAFT',$3)
       ON CONFLICT(company_id,period) DO UPDATE SET status='DRAFT'
       RETURNING id`, [body.company_id, period+'-01', ind.id]);
    await ds.destroy();
    return { payrun_id: pr[0].id, message: 'Cálculo iniciado (stub)'};
  }
}