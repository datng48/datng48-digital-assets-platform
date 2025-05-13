# This README covers test cases should implement and setup preparation

# Unit test
## Models
#### User Model
* Test password authentication methods (encrypt_password and authenticate)
* Test validations for required fields (email, name, role, password)\
* Test enum definitions and scopes
* Test relationships with other models (assets, purchases)
* Test methods like total_earnings, can_purchase?, owns?

#### Asset Model

* Test validations (title, description, file_url, price)
* Test relationships with User and Purchase
* Test bulk_import functionality
* Test purchased_by? method

#### Purchase Model

* Test basic validations
* Test custom validations (user_cannot_purchase_own_asset, user_must_be_customer, no_duplicate_purchase)
* Test relationships with User and Asset

## Controller
#### AuthController
* Test successful registration
* Test registration with invalid data
* Test successful login
* Test failed login attempts

#### AssetController
* Test bulk asset import

#### PurchasesController
* Test fetching user's purchases
* Test successful purchase update
* Test attempting to purchase already purchased assets
* Test fetching purchased assets

## System test

Frontend-Backend Integration:: 
* Test API responses properly update the UI
* Test purchase status correctly reflects in the frontend
* Test authentication state persists properly
Error Handling:
Test good error messages for various validation failures
Test unauthorized access attempts
Test handling of duplicate purchases

## Perofmrnace test
* Test bulk import with large datasets
* Test concurrent purchases of the same asset
* Test loading performance with many assets

## DB design relationship:

![Image](https://github.com/user-attachments/assets/b4d917aa-9a17-43fe-949e-0956267666eb)

## Features:
* Authentication ( login, register, validation, etc )
* Pagination
* CRUD

## Tech stack:
* Ruby on Rails, Postgresql, ReactJS, TailwindCSS, Antd

## Images

![Image](https://github.com/user-attachments/assets/e16f416e-c3fb-47b6-b3e4-e951e06261c5)
![Image](https://github.com/user-attachments/assets/bf8e29dd-7c27-4de3-b29f-736b77d4c3a0)
![Image](https://github.com/user-attachments/assets/663486ee-6cbc-40f8-829f-13ecdee19687)

## Demo:
Link: https://www.youtube.com/watch?v=_b0ZkIWOAJI

