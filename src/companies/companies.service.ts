import { Injectable } from '@nestjs/common';
import { AppDataSource } from '../../../ormconfig';

@Injectable()
export class CompaniesService {
  async create(body: any) {
    const ds = await AppDataSource.initialize();
    const { rut, legal_name, fantasy_name } = body;
    const res = await ds.query(
      'INSERT INTO company(id,rut,legal_name,fantasy_name) VALUES(uuid_generate_v4(),$1,$2,$3) RETURNING id',
      [rut, legal_name, fantasy_name || null],
    );
    await ds.destroy();
    return { id: res[0].id };
  }
}