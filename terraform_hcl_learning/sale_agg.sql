select Store_id as store_id
, Product_category as product_category
,sum(number_of_pieces_sold) as total_quantity
,sum(number_of_pieces_sold * (sell_price - buy_rate)) as profit
from `dna-poc-training.ds_toanbui1991.sales_toanbui1991`
group by Store_id, Product_category