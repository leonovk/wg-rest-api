# frozen_string_literal: true

WireGuard::Repository.new.connection.create_table :server_configs do
  primary_key :id
  String :private_key, null: false
  String :public_key, null: false
  String :address, null: false
  String :address_ipv6, null: false
end

WireGuard::Repository.new.connection.create_table :client_configs do
  primary_key :id
  String :address, unique: true, null: false
  String :address_ipv6, unique: true, null: false
  String :private_key
  String :public_key, unique: true, null: false
  String :preshared_key
  Boolean :enable, default: true, null: false
  column :data, :json, default: {}.to_json, null: false
end

WireGuard::Repository.new.connection.create_table :client_stats do
  primary_key :id
  String :public_key, unique: true, null: false
  DateTime :last_online
  Integer :received
  Integer :sent
end

WireGuard::Repository.new.connection.create_table :client_events do
  primary_key :id
  String :public_key, unique: true
  String :kind, null: false
end
