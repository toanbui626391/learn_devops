--create view
CREATE VIEW ds_toanbui1991.vw_transaction(transaction_date, name, address, workplace, bank_account_number, transaction_amnt) AS (
  SELECT transaction_date
  ,c.name AS name
  , address
  , workplace
  , bank_account_number
  , transaction_amnt
  FROM `dna-poc-training.ds_toanbui1991.customer` AS c
  LEFT JOIN `dna-poc-training.ds_toanbui1991.fact_transaction` AS t ON c.name = t.name 
);
--check view data
select * from `dna-poc-training.ds_toanbui1991.vw_transaction`;