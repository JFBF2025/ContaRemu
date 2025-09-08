INSERT INTO pay_item_type(code,name,kind,taxable,pensionable,healthable,formula) VALUES
('SB','Sueldo base','EARNING', TRUE, TRUE, TRUE, '{"type":"fixed","source":"contract.base_salary"}')
ON CONFLICT (code) DO NOTHING;

-- (Puedes agregar más ítems luego, como HEX, GRAT, AFP, SALUD, etc.)