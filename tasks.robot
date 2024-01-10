*** Settings ***
Documentation       Template robot main suite.
# Documentation     Orders robots from RobotSpareBin Industries Inc.
# ...               Saves the order HTML receipt as a PDF file.
# ...               Saves the screenshot of the ordered robot.
# ...               Embeds the screenshot of the robot to the PDF receipt.
# ...               Creates ZIP archive of the receipts and the images.


Library    RPA.Browser.Selenium    auto_close=${FALSE} 
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.PDF
Library    OperatingSystem
# Library    RPA.JavaAccessBridge
Library    RPA.Archive

*** Tasks ***
# Minimal task
#     Log    Done.
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download order file
    Fill in the order forms using excel file
    # Fill and submit order
    Save files as ZIP
    
*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

Download order file
    Download    https://robotsparebinindustries.com/orders.csv   overwrite=${True}

Fill in the order forms using excel file
#     # Open Workbook   orders.csv
#     # ${order_datas}    Read Worksheet As Table    header=True
#     # Close Workbook
    
    ${order_datas}    Read table from CSV    orders.csv

    FOR    ${order_data}    IN    @{order_datas}
        # Fill and submit order    ${order_data}
        Wait Until Keyword Succeeds    5x    0.5s    Fill and submit order    ${order_data}
        Click Button    Order another robot
        Wait Until Element Is Visible    class:modal
        Click Button    OK
    END

Fill and submit order
    [Arguments]    ${order_data}
    Select From List By Value    head     ${order_data}[Head]
    Select Radio Button    body   ${order_data}[Body]
    Input Text    class:form-control  ${order_data}[Legs]
    Input Text    address    ${order_data}[Address]
    # Submit Form
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)    #robot cannot click the button it cannot see, so need to scroll to the bottom
    Sleep    1s   # Wait for the page to scroll
    Click Button    Order
    Print as PDF and screenshot receipt    ${order_data}
    # Sleep    10s 

    # Wait Until Element Is Visible    id:receipt
    # Click Button    Order another robot
    # Sleep    1s 
    # Wait Until Element Is Visible    class:modal
    # Click Button    OK
    
    # Select From List By Value    head     1
    # Select Radio Button    body   2
    # Input Text    class:form-control   3
    # Input Text    address    Address 123
    # # Scroll Element Into View    xpath://button[text()='Order']
    # Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)    #robot cannot click the button it cannot see, so need to scroll to the bottom
    # Sleep    2s   # Wait for the page to scroll
    # # Execute JavaScript    document.querySelector("button[text()='Order']").click()
    # Click Button    Order
    # Sleep    2s 
    # Click Button    Order another robot
    

Print as PDF and screenshot receipt 
    [Arguments]    ${order_data}
    ${receipt_html}    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipt_pdf/sales_${order_data}[Order number].pdf
    Screenshot    css:div.alert-success   ${OUTPUT_DIR}${/}receipt_screenshot/sales_${order_data}[Order number].png    #target css class alert-success
    
    ${order_number}    Set Variable    ${order_data}[Order number]
    # Log    ${order_number}
    
    Create Directory    output/receipt_pdf_screenshot

    ${files}=    Create List
    ...    output/receipt_pdf/sales_${order_number}.pdf
    ...    output/receipt_screenshot/sales_${order_number}.png
 

    Add Files To PDF    ${files}    ${OUTPUT_DIR}${/}receipt_pdf_screenshot/sales_${order_number}_with_screenshot.pdf

    # Open Pdf    output/receipt_pdf/sales_${order_number}.pdf
    # # Add Files To Pdf    output/receipt_screenshot/sales_${order_number}.png
    # Add Files To Pdf    ${files}
    # # Print To Pdf    output/receipt_screenshot/sales_${order_number}.png
    # Save Pdf    ${OUTPUT_DIR}${/}receipt_pdf_screenshot/sales_${order_number}.pdf


    # Close Pdf

Save files as ZIP
        ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/receipt_files.zip
        Archive Folder With Zip
    ...    output/receipt_pdf_screenshot
    ...    ${zip_file_name}
    


