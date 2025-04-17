# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_10_181146) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bscf_core_addresses", force: :cascade do |t|
    t.string "city"
    t.string "sub_city"
    t.string "woreda"
    t.string "latitude"
    t.string "longitude"
    t.string "house_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bscf_core_business_documents", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "document_number", null: false
    t.string "document_name", null: false
    t.string "document_description"
    t.datetime "verified_at"
    t.boolean "is_verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_bscf_core_business_documents_on_business_id"
  end

  create_table "bscf_core_businesses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name", null: false
    t.string "tin_number", null: false
    t.integer "business_type", default: 0, null: false
    t.datetime "verified_at"
    t.integer "verification_status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bscf_core_businesses_on_user_id"
  end

  create_table "bscf_core_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bscf_core_delivery_order_items", force: :cascade do |t|
    t.bigint "delivery_order_id", null: false
    t.bigint "order_item_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_order_id"], name: "index_bscf_core_delivery_order_items_on_delivery_order_id"
    t.index ["order_item_id"], name: "index_bscf_core_delivery_order_items_on_order_item_id"
    t.index ["product_id"], name: "index_bscf_core_delivery_order_items_on_product_id"
  end

  create_table "bscf_core_delivery_orders", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "dropoff_address_id", null: false
    t.string "driver_phone", null: false
    t.text "delivery_notes"
    t.datetime "estimated_delivery_time", null: false
    t.datetime "delivery_start_time"
    t.datetime "delivery_end_time"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "driver_id"
    t.bigint "pickup_address_id", null: false
    t.string "buyer_phone", null: false
    t.string "seller_phone", null: false
    t.datetime "actual_delivery_time"
    t.index ["driver_id"], name: "index_bscf_core_delivery_orders_on_driver_id"
    t.index ["dropoff_address_id"], name: "index_bscf_core_delivery_orders_on_dropoff_address_id"
    t.index ["order_id"], name: "index_bscf_core_delivery_orders_on_order_id"
    t.index ["pickup_address_id"], name: "index_bscf_core_delivery_orders_on_pickup_address_id"
  end

  create_table "bscf_core_marketplace_listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "listing_type", null: false
    t.integer "status", null: false
    t.boolean "allow_partial_match", default: false, null: false
    t.datetime "preferred_delivery_date"
    t.datetime "expires_at"
    t.boolean "is_active", default: true
    t.bigint "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_bscf_core_marketplace_listings_on_address_id"
    t.index ["user_id"], name: "index_bscf_core_marketplace_listings_on_user_id"
  end

  create_table "bscf_core_order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.bigint "quotation_item_id"
    t.float "quantity", null: false
    t.float "unit_price", null: false
    t.float "subtotal", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_bscf_core_order_items_on_order_id"
    t.index ["product_id"], name: "index_bscf_core_order_items_on_product_id"
    t.index ["quotation_item_id"], name: "index_bscf_core_order_items_on_quotation_item_id"
  end

  create_table "bscf_core_orders", force: :cascade do |t|
    t.bigint "ordered_by_id"
    t.bigint "ordered_to_id"
    t.bigint "quotation_id"
    t.integer "order_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.float "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ordered_by_id"], name: "index_bscf_core_orders_on_ordered_by_id"
    t.index ["ordered_to_id"], name: "index_bscf_core_orders_on_ordered_to_id"
    t.index ["quotation_id"], name: "index_bscf_core_orders_on_quotation_id"
  end

  create_table "bscf_core_products", force: :cascade do |t|
    t.string "sku", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.bigint "category_id", null: false
    t.decimal "base_price", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_bscf_core_products_on_category_id"
    t.index ["sku"], name: "index_bscf_core_products_on_sku", unique: true
  end

  create_table "bscf_core_quotation_items", force: :cascade do |t|
    t.bigint "quotation_id", null: false
    t.bigint "rfq_item_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", null: false
    t.integer "unit", null: false
    t.decimal "subtotal", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_bscf_core_quotation_items_on_product_id"
    t.index ["quotation_id"], name: "index_bscf_core_quotation_items_on_quotation_id"
    t.index ["rfq_item_id"], name: "index_bscf_core_quotation_items_on_rfq_item_id"
  end

  create_table "bscf_core_quotations", force: :cascade do |t|
    t.bigint "request_for_quotation_id", null: false
    t.bigint "business_id", null: false
    t.decimal "price", null: false
    t.date "delivery_date", null: false
    t.datetime "valid_until", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_bscf_core_quotations_on_business_id"
    t.index ["request_for_quotation_id"], name: "index_bscf_core_quotations_on_request_for_quotation_id"
  end

  create_table "bscf_core_request_for_quotations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bscf_core_request_for_quotations_on_user_id"
  end

  create_table "bscf_core_rfq_items", force: :cascade do |t|
    t.bigint "request_for_quotation_id", null: false
    t.bigint "product_id", null: false
    t.float "quantity", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_bscf_core_rfq_items_on_product_id"
    t.index ["request_for_quotation_id"], name: "index_bscf_core_rfq_items_on_request_for_quotation_id"
  end

  create_table "bscf_core_roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bscf_core_user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date_of_birth", null: false
    t.string "nationality", null: false
    t.string "occupation", null: false
    t.string "source_of_funds", null: false
    t.integer "kyc_status", default: 0
    t.integer "gender", null: false
    t.datetime "verified_at"
    t.bigint "verified_by_id"
    t.bigint "address_id", null: false
    t.string "fayda_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_bscf_core_user_profiles_on_address_id"
    t.index ["user_id"], name: "index_bscf_core_user_profiles_on_user_id"
    t.index ["verified_by_id"], name: "index_bscf_core_user_profiles_on_verified_by_id"
  end

  create_table "bscf_core_user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_bscf_core_user_roles_on_role_id"
    t.index ["user_id"], name: "index_bscf_core_user_roles_on_user_id"
  end

  create_table "bscf_core_users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "phone_number", null: false
    t.string "password_digest", limit: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_bscf_core_users_on_email", unique: true
    t.index ["phone_number"], name: "index_bscf_core_users_on_phone_number", unique: true
  end

  create_table "bscf_core_vehicles", force: :cascade do |t|
    t.bigint "driver_id"
    t.string "plate_number", null: false
    t.string "vehicle_type", null: false
    t.string "brand", null: false
    t.string "model", null: false
    t.integer "year", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_bscf_core_vehicles_on_driver_id"
    t.index ["plate_number"], name: "index_bscf_core_vehicles_on_plate_number", unique: true
  end

  create_table "bscf_core_virtual_account_transactions", force: :cascade do |t|
    t.bigint "from_account_id", null: false
    t.bigint "to_account_id", null: false
    t.decimal "amount", null: false
    t.integer "transaction_type", null: false
    t.integer "status", default: 0, null: false
    t.string "reference_number", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_account_id", "reference_number"], name: "idx_on_from_account_id_reference_number_ecc8e65d8f"
    t.index ["from_account_id"], name: "idx_on_from_account_id_643ea7341d"
    t.index ["reference_number"], name: "idx_on_reference_number_9aa4ea6333", unique: true
    t.index ["to_account_id", "reference_number"], name: "idx_on_to_account_id_reference_number_6f4048491d"
    t.index ["to_account_id"], name: "index_bscf_core_virtual_account_transactions_on_to_account_id"
  end

  create_table "bscf_core_virtual_accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "account_number", null: false
    t.string "cbs_account_number", null: false
    t.decimal "balance", default: "0.0", null: false
    t.decimal "interest_rate", default: "0.0", null: false
    t.integer "interest_type", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.string "branch_code", null: false
    t.string "product_scheme", null: false
    t.string "voucher_type", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_number"], name: "index_bscf_core_virtual_accounts_on_account_number", unique: true
    t.index ["branch_code"], name: "index_bscf_core_virtual_accounts_on_branch_code"
    t.index ["cbs_account_number"], name: "index_bscf_core_virtual_accounts_on_cbs_account_number", unique: true
    t.index ["user_id", "account_number"], name: "index_bscf_core_virtual_accounts_on_user_id_and_account_number"
    t.index ["user_id"], name: "index_bscf_core_virtual_accounts_on_user_id"
  end

  create_table "bscf_core_wholesaler_products", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.bigint "product_id", null: false
    t.integer "minimum_order_quantity", default: 1, null: false
    t.decimal "wholesale_price"
    t.integer "available_quantity", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_bscf_core_wholesaler_products_on_business_id"
    t.index ["product_id"], name: "index_bscf_core_wholesaler_products_on_product_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bscf_core_business_documents", "bscf_core_businesses", column: "business_id"
  add_foreign_key "bscf_core_businesses", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_delivery_order_items", "bscf_core_delivery_orders", column: "delivery_order_id"
  add_foreign_key "bscf_core_delivery_order_items", "bscf_core_order_items", column: "order_item_id"
  add_foreign_key "bscf_core_delivery_order_items", "bscf_core_products", column: "product_id"
  add_foreign_key "bscf_core_delivery_orders", "bscf_core_addresses", column: "dropoff_address_id"
  add_foreign_key "bscf_core_delivery_orders", "bscf_core_addresses", column: "pickup_address_id"
  add_foreign_key "bscf_core_delivery_orders", "bscf_core_orders", column: "order_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "bscf_core_delivery_orders", "bscf_core_users", column: "driver_id"
  add_foreign_key "bscf_core_marketplace_listings", "bscf_core_addresses", column: "address_id"
  add_foreign_key "bscf_core_marketplace_listings", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_order_items", "bscf_core_orders", column: "order_id"
  add_foreign_key "bscf_core_order_items", "bscf_core_products", column: "product_id"
  add_foreign_key "bscf_core_order_items", "bscf_core_quotation_items", column: "quotation_item_id"
  add_foreign_key "bscf_core_orders", "bscf_core_quotations", column: "quotation_id"
  add_foreign_key "bscf_core_orders", "bscf_core_users", column: "ordered_by_id"
  add_foreign_key "bscf_core_orders", "bscf_core_users", column: "ordered_to_id"
  add_foreign_key "bscf_core_products", "bscf_core_categories", column: "category_id"
  add_foreign_key "bscf_core_quotation_items", "bscf_core_products", column: "product_id"
  add_foreign_key "bscf_core_quotation_items", "bscf_core_quotations", column: "quotation_id"
  add_foreign_key "bscf_core_quotation_items", "bscf_core_rfq_items", column: "rfq_item_id"
  add_foreign_key "bscf_core_quotations", "bscf_core_businesses", column: "business_id"
  add_foreign_key "bscf_core_quotations", "bscf_core_request_for_quotations", column: "request_for_quotation_id"
  add_foreign_key "bscf_core_request_for_quotations", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_rfq_items", "bscf_core_products", column: "product_id"
  add_foreign_key "bscf_core_rfq_items", "bscf_core_request_for_quotations", column: "request_for_quotation_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_addresses", column: "address_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_users", column: "verified_by_id"
  add_foreign_key "bscf_core_user_roles", "bscf_core_roles", column: "role_id"
  add_foreign_key "bscf_core_user_roles", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_vehicles", "bscf_core_users", column: "driver_id"
  add_foreign_key "bscf_core_virtual_account_transactions", "bscf_core_virtual_accounts", column: "from_account_id"
  add_foreign_key "bscf_core_virtual_account_transactions", "bscf_core_virtual_accounts", column: "to_account_id"
  add_foreign_key "bscf_core_virtual_accounts", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_wholesaler_products", "bscf_core_businesses", column: "business_id"
  add_foreign_key "bscf_core_wholesaler_products", "bscf_core_products", column: "product_id"
end
