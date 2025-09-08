import { Injectable } from '@nestjs/common';
@Injectable()
export class ExportsService {
  generatePreviRed(rows: any[]) {
    const headers = ['RUT','DV','NOMBRE','AFP','IMPO','SALUD','AFC_EMP','AFC_TRAB'];
    const lines = [headers.join(';')];
    for(const r of rows){
      lines.push([r.rut.split('-')[0], r.rut.split('-')[1], r.name, r.afp, r.base, r.salud, r.afc_emp, r.afc_trab].join(';'));
    }
    return lines.join('\n');
  }
  generateLREPayload(payrunId: string, items: any[]) {
    return {
      payrunId,
      periodo: '',
      empresa: {},
      trabajadores: items.map(i => ({ rut: i.rut, imponible: i.pensionable, salud: i.health, iusc: i.iusc })),
      resumen: { total_imponible: 0, total_descuentos: 0 }
    };
  }
}
