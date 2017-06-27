TODO:

1.) Figure out how to access reservations data.
  => Customer name, room booked, Check-in date, check-out date, misc. notes

  => Current ideas:
    1. Parse email for the confirmation email when a reservation is made

    2. Find an Airbnb api

    3. Scrape the Airbnb website for the data:
      - Dino login/auth
      - Page click

2.) Use data to create Ruby objects of each reservation
      => persist in Postgresql database
3.) Render the current reservations in the view
      => ALL reservations WHERE Date.now > Checkin && Date.now < Checkout
4.) ActiveAdmin to Crud new reservations if a current guest wants to extend the reservation

