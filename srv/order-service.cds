using {sap.capire.orders as my} from '../db/schema';

service OrderService {

    @odata.draft.enabled
    entity Orders as projection on my.Orders;

    entity OrderItems as projection on my.OrderItems;
    entity Customers as projection on my.Customers;
   
    entity Products as projection on my.Products;
    entity Shipments as projection on my.Shipments;
    entity OrderStatus as projection on my.OrderStatus;
}

//annotate OrderService with @(requires: 'admin');


