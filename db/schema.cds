using { cuid, managed, sap.common.CodeList} from '@sap/cds/common';
namespace sap.capire.orders; 

entity Customers : cuid, managed {
  customerId   : String(20);
  name         : String(100);
  email        : String(100);
  phone        : String(20); 
  address      : String(255);
}

entity Products : cuid, managed {
  productId    : String(20);
  name         : String(100);
  description  : String(255);
  price        : Decimal(13,2);
}

entity Orders : cuid, managed {
  orderId      : String(20);
  orderName    : String(100);
  orderDate    : Date;

  customer     : Association to Customers;

  status       : Association to OrderStatus;
  shipment     : Association to Shipments
                on shipment.order = $self;
  totalAmount  : Decimal(15,2);

  items        : Composition of many OrderItems
                   on items.order = $self;

  
}

entity OrderItems : cuid {
  order        : Association to Orders;
  product      : Association to Products;

  quantity     : Integer;
  unitPrice    : Decimal(13,2);
}

entity Shipments : cuid, managed {
  order        : Association to Orders;
  shipmentId   : String(30);
  carrier      : String(50);
  trackingNo   : String(50);
  status       : String(30);   // In Transit, Delivered
  estimatedDelivery : Date;
}

entity OrderStatus : CodeList {
  key code : String(10);
  text     : String(50);
}
