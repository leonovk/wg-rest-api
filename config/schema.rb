# frozen_string_literal: true

DB::CONNECTOR.create_table :server_configs do
  primary_key :id
  String :private_key
  String :public_key
  String :address
  String :address_ipv6
end

DB::CONNECTOR.create_table :client_configs do
  primary_key :id
  String :address
  String :address_ipv6
  String :private_key
  String :public_key, unique: true
  String :preshared_key
  Boolean :enable
  column :data, :json
end

DB::CONNECTOR.create_table :client_stats do
  primary_key :id
  String :public_key, unique: true
  DateTime :last_online
  Integer :received
  Integer :sent
end

DB::CONNECTOR.create_table :client_events do
  primary_key :id
  String :public_key, unique: true
  String :kind
end
