-- Migration to add address, birthday, and phone number to user_profiles table
ALTER TABLE user_profiles
ADD COLUMN address VARCHAR(255),
ADD COLUMN birthday DATE,
ADD COLUMN phone_number VARCHAR(20);
