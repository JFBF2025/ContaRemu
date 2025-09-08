import { Body, Controller, Param, Post } from '@nestjs/common';
import { ExportsService } from './exports.service';

@Controller('exports')
export class ExportsController {
  constructor(private svc: ExportsService) {}
  @Post('previ/:period')
  previ(@Param('period') p: string, @Body() body: any) {
    const txt = this.svc.generatePreviRed(body.rows || []);
    return { filename: `previ_${p}.csv`, content: txt };
  }
  @Post('lre/:period')
  lre(@Param('period') p: string, @Body() body: any) {
    return this.svc.generateLREPayload(body.payrunId, body.items || []);
  }
}