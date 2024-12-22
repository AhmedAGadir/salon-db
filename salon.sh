#! /bin/bash
# -t (tuples only) and -A (no align) flags will stop us reading column headers and formatting
PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

# empty tables and sequences
# $PSQL "TRUNCATE services, customers, appointments;"
# $PSQL "ALTER SEQUENCE services_service_id_seq RESTART WITH 1;"
# $PSQL "ALTER SEQUENCE customers_service_id_seq RESTART WITH 1;"
# $PSQL "ALTER SEQUENCE appointments_service_id_seq RESTART WITH 1;"
# $PSQL "INSERT INTO services(name) VALUES('Haircut'), ('Beard Trim'), ('Hair Dye')";

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  echo -e "Select a service:\n"

  # display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id");
  if [[ -z $SERVICES ]]
  then
    echo "No Services currently available"
  else
    echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME;
    do
      echo "$SERVICE_ID) $NAME"
    done 
  fi

  # Get user selection
  read SERVICE_ID_SELECTED;

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Selection must be a number from the list of services."
  else 
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # if service doesnt exist
    if [[ -z SERIVCE_NAME ]]
      then
        # send them back to main menu
        MAIN_MENU "Select a service from the list of services"
      else 
        # get phone number
        echo -e "\nEnter your phone number:\n"
        read CUSTOMER_PHONE

        # get customer id from phone number
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'");
        echo "customer id $CUSTOMER_ID"


        # if customer id doesnt exist
        if [[ -z $CUSTOMER_ID ]]
        then
          # get customer name
          echo -e "\nEnter your name:\n"
          read CUSTOMER_NAME

          # create a new record for the customer
          CUSTOMER_ENTRY_RESPONSE=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

          # get the id for the new customer and assign it to the customer_id variable
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'");
      fi 

      # get time for appointment
      echo -e "\nEnter a time for your appointment in the form hh:mm\n"
      read SERVICE_TIME

      # customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID");

      # create the appointment record
      APPOINTMENT_ENTRY_RESPONSE=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"

    fi
  fi

}


MAIN_MENU 

