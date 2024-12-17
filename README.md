# Kreditrechner Shiny App

## Overview
The "Kreditrechner" is a Shiny application designed to help users calculate various aspects of a home loan. It allows users to input their financial details and visualize the loan amortization schedule, calculate the monthly payment, loan duration, and remaining balance after the fixed interest period.

## Features
- Input financial parameters such as house price, down payment (Eigenkapital), additional costs as a percentage, repayment rate, interest rate, and fixed interest duration.
- Calculate the loan amount, monthly payment, total loan duration, and remaining balance after the fixed interest period.
- Visualize the remaining debt over time and the breakdown of monthly payments into interest and principal components using interactive plots.

## Requirements
To run this app, you’ll need the following R libraries installed:
- `shiny`
- `shinydashboard`
- `tidyverse`
- `lubridate`

## Usage Instructions

1. **Launch the App**: Deploy and run this app using R, RStudio, or another environment supporting Shiny applications.

2. **Input Parameters**:
   - **Eigenkapital**: Enter your available funds for the down payment.
   - **Hauspreis**: Specify the total house price.
   - **Nebenkosten (% vom Hauspreis)**: Input additional costs as a percentage of the house price.
   - **Tilgungsrate in %**: Set the repayment rate percentage.
   - **Zinsbindungsdauer**: Choose the duration for the fixed interest rate (5, 10, or 15 years).
   - **Zinssatz eff. p.a. (%):** Enter the effective annual interest rate.

3. **View Calculations**: The app displays:
   - **Kreditbetrag**: The total loan amount.
   - **Monatl. Rate**: The monthly installment amount.
   - **Laufzeit**: Total loan term in years and months.
   - **Restschuld nach Zinsbindung**: Remaining debt after the fixed interest period.

4. **Visualizations**:
   - **Remaining Debt Plot**: Tracks the remaining loan balance over time.
   - **Rate Components Plot**: Illustrates the monthly payment components into interest and principal repayment.

## How It Works
- **Backend Calculations**: The server function computes the amortization schedule based on user inputs. It determines the loan amount, monthly payment, loan duration, and remaining balance after the fixed interest period.
- **Visualization**: The app uses `ggplot2` to plot the amortization schedule and payment components, providing users with a clear understanding of their loan repayment process.

## Customize
Feel free to modify the app’s layout or functionalities by editing the `ui` and `server` sections of the script as per your specific requirements or preferences.

## Credits
Developed using Shiny and R’s tidyverse packages, leveraging data visualization and reactive programming capabilities to model loan computations effectively.
