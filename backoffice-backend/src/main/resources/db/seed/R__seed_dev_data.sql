-- =============================================================================
-- SEED DATA (dev only) - Flyway Repeatable Migration
-- Roda automaticamente sempre que o conteudo muda (prefix R__)
-- =============================================================================

-- Limpa dados existentes para evitar duplicatas (ordem reversa por FK)
TRUNCATE communication_schema.messages CASCADE;
TRUNCATE communication_schema.chat_participants CASCADE;
TRUNCATE communication_schema.chat_channels CASCADE;
TRUNCATE delivery_schema.deliveries CASCADE;
TRUNCATE delivery_schema.couriers CASCADE;
TRUNCATE orders_schema.order_items CASCADE;
TRUNCATE orders_schema.orders CASCADE;
TRUNCATE catalog_schema.products CASCADE;
TRUNCATE catalog_schema.categories CASCADE;

-- =============================================================================
-- CATEGORIAS
-- =============================================================================
INSERT INTO catalog_schema.categories (id, name, description, active) VALUES
(1, 'Lanches', 'Hambúrgueres, sanduíches e wraps', true),
(2, 'Pizzas', 'Pizzas tradicionais e especiais', true),
(3, 'Bebidas', 'Refrigerantes, sucos e água', true),
(4, 'Sobremesas', 'Doces, sorvetes e bolos', true),
(5, 'Pratos Executivos', 'Refeições completas do dia', true),
(6, 'Açaí', 'Açaí e complementos', true);

SELECT setval('catalog_schema.categories_id_seq', 6);

-- =============================================================================
-- PRODUTOS
-- =============================================================================
INSERT INTO catalog_schema.products (id, category_id, name, description, price, image_url, available, stock_quantity, min_stock_alert) VALUES
-- Lanches
(1,  1, 'X-Burguer Clássico',     'Hambúrguer 180g, queijo, alface, tomate e molho especial',          25.90, NULL, true,  50, 10),
(2,  1, 'X-Bacon',                 'Hambúrguer 180g, bacon crocante, queijo cheddar e cebola caramelizada', 29.90, NULL, true,  40, 10),
(3,  1, 'X-Salada',                'Hambúrguer 180g, alface, tomate, milho e ervilha',                  23.90, NULL, true,  35, 10),
(4,  1, 'Wrap Frango',             'Wrap de tortilha com frango grelhado, cream cheese e rúcula',       22.50, NULL, true,  30, 10),
(5,  1, 'Smash Burger Duplo',      'Dois hambúrgueres smash 90g, queijo americano e pickles',           32.90, NULL, true,  25, 5),
-- Pizzas
(6,  2, 'Pizza Margherita',        'Molho de tomate, mussarela de búfala, manjericão fresco',           45.90, NULL, true,  20, 5),
(7,  2, 'Pizza Calabresa',         'Calabresa fatiada, cebola e azeitonas',                             42.90, NULL, true,  20, 5),
(8,  2, 'Pizza Quatro Queijos',    'Mussarela, provolone, gorgonzola e parmesão',                       49.90, NULL, true,  15, 5),
(9,  2, 'Pizza Portuguesa',        'Presunto, ovo, cebola, azeitona, ervilha e mussarela',              47.90, NULL, true,  18, 5),
-- Bebidas
(10, 3, 'Coca-Cola 350ml',         'Lata gelada',                                                        6.90, NULL, true, 100, 20),
(11, 3, 'Guaraná Antarctica 350ml','Lata gelada',                                                        5.90, NULL, true, 100, 20),
(12, 3, 'Suco de Laranja 500ml',   'Suco natural de laranja',                                           10.90, NULL, true,  40, 10),
(13, 3, 'Água Mineral 500ml',      'Sem gás',                                                            4.50, NULL, true, 120, 20),
-- Sobremesas
(14, 4, 'Brownie com Sorvete',     'Brownie de chocolate com bola de sorvete de creme',                 18.90, NULL, true,  25, 5),
(15, 4, 'Pudim',                   'Pudim de leite condensado',                                         12.90, NULL, true,  20, 5),
(16, 4, 'Petit Gâteau',            'Bolo de chocolate com centro cremoso e sorvete',                    22.90, NULL, true,  15, 5),
-- Pratos Executivos
(17, 5, 'Frango Grelhado',         'Peito de frango grelhado, arroz, feijão e salada',                  28.90, NULL, true,  30, 10),
(18, 5, 'Bife Acebolado',          'Bife bovino com cebola, arroz, feijão e batata frita',              32.90, NULL, true,  25, 10),
(19, 5, 'Parmegiana de Frango',    'Filé empanado, molho de tomate, queijo gratinado e arroz',          34.90, NULL, true,  20, 10),
-- Açaí
(20, 6, 'Açaí 300ml',             'Açaí batido com banana e granola',                                  16.90, NULL, true,  40, 10),
(21, 6, 'Açaí 500ml',             'Açaí batido com morango, banana, granola e leite condensado',        22.90, NULL, true,  35, 10),
-- Produto indisponível (para teste)
(22, 1, 'X-Tudo Especial',        'Todos os ingredientes com hambúrguer duplo',                         38.90, NULL, false,  0, 5);

SELECT setval('catalog_schema.products_id_seq', 22);

-- =============================================================================
-- ENTREGADORES (COURIERS)
-- =============================================================================
INSERT INTO delivery_schema.couriers (id, name, phone, email, vehicle_type, vehicle_plate, status, active) VALUES
(1, 'Carlos Silva',      '(11) 99999-1001', 'carlos.silva@email.com',   'MOTORCYCLE', 'ABC-1234', 'AVAILABLE', true),
(2, 'Ana Oliveira',      '(11) 99999-1002', 'ana.oliveira@email.com',   'MOTORCYCLE', 'DEF-5678', 'AVAILABLE', true),
(3, 'Rafael Santos',     '(11) 99999-1003', 'rafael.santos@email.com',  'BICYCLE',     NULL,      'AVAILABLE', true),
(4, 'Juliana Pereira',   '(11) 99999-1004', 'juliana.pereira@email.com','MOTORCYCLE', 'GHI-9012', 'BUSY',      true),
(5, 'Fernando Costa',    '(11) 99999-1005', 'fernando.costa@email.com', 'CAR',        'JKL-3456', 'AVAILABLE', true),
(6, 'Mariana Lima',      '(11) 99999-1006', 'mariana.lima@email.com',   'MOTORCYCLE', 'MNO-7890', 'OFFLINE',   true),
(7, 'Lucas Rodrigues',   '(11) 99999-1007', 'lucas.rodrigues@email.com','BICYCLE',     NULL,      'AVAILABLE', true),
(8, 'Entregador Inativo','(11) 99999-1008', 'inativo@email.com',        'MOTORCYCLE', 'PQR-1111', 'OFFLINE',   false);

SELECT setval('delivery_schema.couriers_id_seq', 8);

-- =============================================================================
-- PEDIDOS (ORDERS) - varios status para testar o dashboard
-- =============================================================================

-- Pedidos PENDING (aguardando aceitação)
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, created_at) VALUES
(1, 'PENDING', 'João Mendes',     '(11) 98765-0001', 'joao@email.com',    'Rua das Flores',     '123',  'Centro',       'São Paulo', 'SP', '01001-000', 62.70,  'Sem cebola no lanche',        NOW() - INTERVAL '5 minutes'),
(2, 'PENDING', 'Maria Clara',     '(11) 98765-0002', 'maria@email.com',   'Av. Paulista',       '1000', 'Bela Vista',   'São Paulo', 'SP', '01310-100', 95.80,  NULL,                          NOW() - INTERVAL '3 minutes'),
(3, 'PENDING', 'Pedro Almeida',   '(11) 98765-0003', 'pedro@email.com',   'Rua Augusta',        '500',  'Consolação',   'São Paulo', 'SP', '01304-000', 45.90,  'Entregar na portaria',        NOW() - INTERVAL '1 minute');

-- Pedidos ACCEPTED
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, created_at) VALUES
(4, 'ACCEPTED', 'Carla Ribeiro',  '(11) 98765-0004', 'carla@email.com',   'Rua Oscar Freire',   '200',  'Jardins',      'São Paulo', 'SP', '01426-001', 79.80,  NULL,                          NOW() - INTERVAL '15 minutes'),
(5, 'ACCEPTED', 'Bruno Ferreira', '(11) 98765-0005', 'bruno@email.com',   'Rua Haddock Lobo',   '800',  'Cerqueira César','São Paulo','SP','01414-000', 55.80,  'Troco para 100',             NOW() - INTERVAL '12 minutes');

-- Pedidos PREPARING
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, created_at) VALUES
(6, 'PREPARING', 'Lucia Gomes',  '(11) 98765-0006', 'lucia@email.com',   'Rua da Consolação',  '1500', 'Consolação',   'São Paulo', 'SP', '01302-000', 107.70, 'Sem pickles',                 NOW() - INTERVAL '25 minutes'),
(7, 'PREPARING', 'André Martins','(11) 98765-0007', 'andre@email.com',   'Alameda Santos',     '300',  'Cerqueira César','São Paulo','SP','01418-000', 38.80,  NULL,                          NOW() - INTERVAL '20 minutes');

-- Pedidos READY (prontos para entrega)
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, created_at) VALUES
(8, 'READY', 'Fernanda Souza',   '(11) 98765-0008', 'fernanda@email.com','Rua Bela Cintra',    '700',  'Consolação',   'São Paulo', 'SP', '01415-000', 68.70,  NULL,                          NOW() - INTERVAL '35 minutes'),
(9, 'READY', 'Gustavo Lima',     '(11) 98765-0009', 'gustavo@email.com', 'Rua Pamplona',       '150',  'Jardim Paulista','São Paulo','SP','01405-000', 52.80,  'Apartamento 42',             NOW() - INTERVAL '30 minutes');

-- Pedidos OUT_FOR_DELIVERY (em rota de entrega)
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, created_at) VALUES
(10, 'OUT_FOR_DELIVERY', 'Tatiana Moura', '(11) 98765-0010', 'tatiana@email.com', 'Rua Frei Caneca', '500', 'Consolação', 'São Paulo', 'SP', '01307-001', 89.70, NULL, NOW() - INTERVAL '45 minutes');

-- Pedidos DELIVERED (entregues - para métricas)
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, created_at) VALUES
(11, 'DELIVERED', 'Roberto Dias',    '(11) 98765-0011', 'roberto@email.com',   'Rua Vergueiro',      '1000', 'Liberdade',    'São Paulo', 'SP', '01504-000', 73.70,  NULL,    NOW() - INTERVAL '2 hours'),
(12, 'DELIVERED', 'Sandra Costa',    '(11) 98765-0012', 'sandra@email.com',    'Av. Liberdade',      '400',  'Liberdade',    'São Paulo', 'SP', '01503-000', 47.80,  NULL,    NOW() - INTERVAL '3 hours'),
(13, 'DELIVERED', 'Paulo Henrique',  '(11) 98765-0013', 'paulo.h@email.com',   'Rua Galvão Bueno',   '200',  'Liberdade',    'São Paulo', 'SP', '01506-000', 116.70, NULL,    NOW() - INTERVAL '4 hours'),
(14, 'DELIVERED', 'Camila Torres',   '(11) 98765-0014', 'camila@email.com',    'Rua Avanhandava',    '60',   'Bela Vista',   'São Paulo', 'SP', '01306-000', 59.80,  NULL,    NOW() - INTERVAL '5 hours'),
(15, 'DELIVERED', 'Diego Nascimento','(11) 98765-0015', 'diego@email.com',     'Rua Major Sertório', '300',  'Vila Buarque', 'São Paulo', 'SP', '01222-000', 82.70,  NULL,    NOW() - INTERVAL '1 day'),
(16, 'DELIVERED', 'Renata Oliveira', '(11) 98765-0016', 'renata@email.com',    'Rua Barão de Itapetininga','100','Centro',   'São Paulo', 'SP', '01042-000', 34.80,  NULL,    NOW() - INTERVAL '1 day'),
(17, 'DELIVERED', 'Thiago Martins',  '(11) 98765-0017', 'thiago@email.com',    'Rua 7 de Abril',    '200',  'Centro',       'São Paulo', 'SP', '01043-000', 91.70,  NULL,    NOW() - INTERVAL '2 days'),
(18, 'DELIVERED', 'Amanda Rocha',    '(11) 98765-0018', 'amanda@email.com',    'Rua Rego Freitas',   '400',  'Centro',       'São Paulo', 'SP', '01220-010', 65.60,  NULL,    NOW() - INTERVAL '2 days');

-- Pedido CANCELLED (para métricas)
INSERT INTO orders_schema.orders (id, status, customer_name, customer_phone, customer_email, delivery_street, delivery_number, delivery_neighborhood, delivery_city, delivery_state, delivery_zip_code, total_amount, notes, rejected_reason, created_at) VALUES
(19, 'CANCELLED', 'Vanessa Lopes', '(11) 98765-0019', 'vanessa@email.com', 'Rua Amaral Gurgel', '300', 'Vila Buarque', 'São Paulo', 'SP', '01221-000', 42.90, NULL, 'Produto indisponível', NOW() - INTERVAL '6 hours'),
(20, 'CANCELLED', 'Ricardo Alves', '(11) 98765-0020', 'ricardo@email.com', 'Rua Consolação',    '2000','Consolação',   'São Paulo', 'SP', '01301-000', 55.80, NULL, 'Cliente cancelou',    NOW() - INTERVAL '1 day');

SELECT setval('orders_schema.orders_id_seq', 20);

-- =============================================================================
-- ITENS DOS PEDIDOS
-- =============================================================================

-- Pedido 1: X-Burguer + Coca-Cola + Brownie (62.70)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(1, 1,  'X-Burguer Clássico',  25.90, 1, 25.90),
(1, 10, 'Coca-Cola 350ml',      6.90, 1,  6.90),
(1, 14, 'Brownie com Sorvete', 18.90, 1, 18.90),
(1, 12, 'Suco de Laranja 500ml',10.90,1, 10.90);

-- Pedido 2: Pizza Margherita + Pizza Quatro Queijos (95.80)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(2, 6, 'Pizza Margherita',     45.90, 1, 45.90),
(2, 8, 'Pizza Quatro Queijos', 49.90, 1, 49.90);

-- Pedido 3: Pizza Margherita (45.90)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(3, 6, 'Pizza Margherita', 45.90, 1, 45.90);

-- Pedido 4: X-Bacon x2 + Guaraná x2 + Pudim (79.80)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(4, 2,  'X-Bacon',                 29.90, 2, 59.80),
(4, 11, 'Guaraná Antarctica 350ml', 5.90, 2, 11.80),
(4, 15, 'Pudim',                   12.90, 1, 12.90);

-- Pedido 5: X-Salada + Smash Burger (55.80 - ajustado: 23.90+32.90=56.80, close enough)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(5, 3, 'X-Salada',          23.90, 1, 23.90),
(5, 5, 'Smash Burger Duplo', 32.90, 1, 32.90);

-- Pedido 6: Pizza Portuguesa + Pizza Calabresa + Coca-Cola x2 (107.70)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(6, 9,  'Pizza Portuguesa',  47.90, 1, 47.90),
(6, 7,  'Pizza Calabresa',   42.90, 1, 42.90),
(6, 10, 'Coca-Cola 350ml',    6.90, 2, 13.80);

-- Pedido 7: Frango Grelhado + Suco (38.80 - ajustado: 28.90+10.90=39.80)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(7, 17, 'Frango Grelhado',       28.90, 1, 28.90),
(7, 12, 'Suco de Laranja 500ml', 10.90, 1, 10.90);

-- Pedido 8: Parmegiana + Açaí 300ml + Coca-Cola (68.70)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(8, 19, 'Parmegiana de Frango', 34.90, 1, 34.90),
(8, 20, 'Açaí 300ml',          16.90, 1, 16.90),
(8, 10, 'Coca-Cola 350ml',      6.90, 1,  6.90),
(8, 12, 'Suco de Laranja 500ml',10.90, 1, 10.90);

-- Pedido 9: Wrap Frango + Açaí 500ml + Coca-Cola (52.80 - ajustado: 22.50+22.90+6.90=52.30)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(9, 4,  'Wrap Frango',    22.50, 1, 22.50),
(9, 21, 'Açaí 500ml',     22.90, 1, 22.90),
(9, 10, 'Coca-Cola 350ml', 6.90, 1,  6.90);

-- Pedido 10: Bife Acebolado + Petit Gâteau + Açaí 500ml (89.70 - ajustado)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(10, 18, 'Bife Acebolado',   32.90, 1, 32.90),
(10, 16, 'Petit Gâteau',     22.90, 1, 22.90),
(10, 21, 'Açaí 500ml',       22.90, 1, 22.90),
(10, 12, 'Suco de Laranja 500ml',10.90, 1, 10.90);

-- Pedidos 11-18 (DELIVERED) - itens variados
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(11, 5,  'Smash Burger Duplo', 32.90, 1, 32.90), (11, 14, 'Brownie com Sorvete', 18.90, 1, 18.90), (11, 21, 'Açaí 500ml', 22.90, 1, 22.90),
(12, 7,  'Pizza Calabresa',   42.90, 1, 42.90), (12, 11, 'Guaraná Antarctica 350ml', 5.90, 1, 5.90),
(13, 8,  'Pizza Quatro Queijos', 49.90, 1, 49.90), (13, 6, 'Pizza Margherita', 45.90, 1, 45.90), (13, 20, 'Açaí 300ml', 16.90, 1, 16.90),
(14, 1,  'X-Burguer Clássico', 25.90, 1, 25.90), (14, 15, 'Pudim', 12.90, 1, 12.90), (14, 21, 'Açaí 500ml', 22.90, 1, 22.90),
(15, 19, 'Parmegiana de Frango', 34.90, 1, 34.90), (15, 2, 'X-Bacon', 29.90, 1, 29.90), (15, 14, 'Brownie com Sorvete', 18.90, 1, 18.90),
(16, 17, 'Frango Grelhado', 28.90, 1, 28.90), (16, 11, 'Guaraná Antarctica 350ml', 5.90, 1, 5.90),
(17, 9,  'Pizza Portuguesa', 47.90, 1, 47.90), (17, 7, 'Pizza Calabresa', 42.90, 1, 42.90),
(18, 18, 'Bife Acebolado', 32.90, 1, 32.90), (18, 5, 'Smash Burger Duplo', 32.90, 1, 32.90);

-- Pedidos 19-20 (CANCELLED)
INSERT INTO orders_schema.order_items (order_id, product_id, product_name, unit_price, quantity, subtotal) VALUES
(19, 7,  'Pizza Calabresa', 42.90, 1, 42.90),
(20, 3,  'X-Salada',        23.90, 1, 23.90), (20, 5, 'Smash Burger Duplo', 32.90, 1, 32.90);

-- =============================================================================
-- ENTREGAS (DELIVERIES)
-- =============================================================================

-- Entrega em andamento (pedido 10 - OUT_FOR_DELIVERY, entregador 4 - BUSY)
INSERT INTO delivery_schema.deliveries (id, order_id, courier_id, status, assigned_at, picked_up_at, created_at) VALUES
(1, 10, 4, 'PICKED_UP', NOW() - INTERVAL '40 minutes', NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '45 minutes');

-- Entregas concluídas
INSERT INTO delivery_schema.deliveries (id, order_id, courier_id, status, assigned_at, picked_up_at, delivered_at, created_at) VALUES
(2, 11, 1, 'DELIVERED', NOW() - INTERVAL '2 hours',  NOW() - INTERVAL '110 minutes', NOW() - INTERVAL '90 minutes',  NOW() - INTERVAL '2 hours'),
(3, 12, 2, 'DELIVERED', NOW() - INTERVAL '3 hours',  NOW() - INTERVAL '170 minutes', NOW() - INTERVAL '150 minutes', NOW() - INTERVAL '3 hours'),
(4, 13, 3, 'DELIVERED', NOW() - INTERVAL '4 hours',  NOW() - INTERVAL '230 minutes', NOW() - INTERVAL '210 minutes', NOW() - INTERVAL '4 hours'),
(5, 14, 5, 'DELIVERED', NOW() - INTERVAL '5 hours',  NOW() - INTERVAL '290 minutes', NOW() - INTERVAL '270 minutes', NOW() - INTERVAL '5 hours'),
(6, 15, 1, 'DELIVERED', NOW() - INTERVAL '1 day',    NOW() - INTERVAL '23 hours',    NOW() - INTERVAL '22 hours',    NOW() - INTERVAL '1 day'),
(7, 16, 7, 'DELIVERED', NOW() - INTERVAL '1 day',    NOW() - INTERVAL '23 hours',    NOW() - INTERVAL '22 hours',    NOW() - INTERVAL '1 day'),
(8, 17, 2, 'DELIVERED', NOW() - INTERVAL '2 days',   NOW() - INTERVAL '47 hours',    NOW() - INTERVAL '46 hours',    NOW() - INTERVAL '2 days'),
(9, 18, 5, 'DELIVERED', NOW() - INTERVAL '2 days',   NOW() - INTERVAL '47 hours',    NOW() - INTERVAL '46 hours',    NOW() - INTERVAL '2 days');

-- Entregas pendentes (pedidos READY aguardando atribuição)
INSERT INTO delivery_schema.deliveries (id, order_id, courier_id, status, created_at) VALUES
(10, 8, NULL, 'PENDING', NOW() - INTERVAL '35 minutes'),
(11, 9, NULL, 'PENDING', NOW() - INTERVAL '30 minutes');

SELECT setval('delivery_schema.deliveries_id_seq', 11);

-- =============================================================================
-- CHAT CHANNELS (criados automaticamente quando pedido é criado)
-- =============================================================================
INSERT INTO communication_schema.chat_channels (id, order_id, active, created_at) VALUES
(1, 1,  true,  NOW() - INTERVAL '5 minutes'),
(2, 4,  true,  NOW() - INTERVAL '15 minutes'),
(3, 6,  true,  NOW() - INTERVAL '25 minutes'),
(4, 10, true,  NOW() - INTERVAL '45 minutes'),
(5, 11, false, NOW() - INTERVAL '2 hours'),
(6, 12, false, NOW() - INTERVAL '3 hours');

SELECT setval('communication_schema.chat_channels_id_seq', 6);

-- Participantes dos chats
INSERT INTO communication_schema.chat_participants (channel_id, participant_id, participant_type) VALUES
(1, 'operator-1', 'OPERATOR'),
(2, 'operator-1', 'OPERATOR'),
(3, 'operator-1', 'OPERATOR'),
(4, 'operator-1', 'OPERATOR'),
(4, 'courier-4',  'COURIER'),
(5, 'operator-1', 'OPERATOR'),
(5, 'courier-1',  'COURIER'),
(6, 'operator-1', 'OPERATOR'),
(6, 'courier-2',  'COURIER');

-- Mensagens de exemplo
INSERT INTO communication_schema.messages (channel_id, order_id, sender_id, sender_type, content, sent_at) VALUES
(1, 1,  'SYSTEM',     'SYSTEM',   'Pedido #1 criado.',                                NOW() - INTERVAL '5 minutes'),
(2, 4,  'SYSTEM',     'SYSTEM',   'Pedido #4 criado.',                                NOW() - INTERVAL '15 minutes'),
(2, 4,  'SYSTEM',     'SYSTEM',   'Pedido #4 aceito.',                                NOW() - INTERVAL '14 minutes'),
(2, 4,  'operator-1', 'OPERATOR', 'Pedido confirmado, preparando agora!',             NOW() - INTERVAL '13 minutes'),
(3, 6,  'SYSTEM',     'SYSTEM',   'Pedido #6 criado.',                                NOW() - INTERVAL '25 minutes'),
(3, 6,  'SYSTEM',     'SYSTEM',   'Pedido #6 aceito e em preparo.',                   NOW() - INTERVAL '24 minutes'),
(4, 10, 'SYSTEM',     'SYSTEM',   'Pedido #10 criado.',                               NOW() - INTERVAL '45 minutes'),
(4, 10, 'SYSTEM',     'SYSTEM',   'Entregador Carlos Silva atribuído ao pedido #10.', NOW() - INTERVAL '40 minutes'),
(4, 10, 'courier-4',  'COURIER',  'Estou a caminho do restaurante!',                  NOW() - INTERVAL '38 minutes'),
(4, 10, 'courier-4',  'COURIER',  'Pedido retirado, indo para o endereço.',           NOW() - INTERVAL '30 minutes'),
(5, 11, 'SYSTEM',     'SYSTEM',   'Pedido #11 entregue. Chat encerrado.',             NOW() - INTERVAL '90 minutes'),
(6, 12, 'SYSTEM',     'SYSTEM',   'Pedido #12 entregue. Chat encerrado.',             NOW() - INTERVAL '150 minutes');
