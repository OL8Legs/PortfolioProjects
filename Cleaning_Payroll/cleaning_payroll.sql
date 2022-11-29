/*

Cleaning the data with SQL

*/

------------------------------------
--Change Base_Pay to a more readable format

Select Base_Pay
From ..Employee_Payroll

Update Employee_Payroll
Set Base_Pay = Convert(decimal(10, 2),Base_Pay)

------------------------------------
--Delete Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By Fiscal_Year,
				 Fiscal_Quarter,
				 Employee_Identifier,
				 Position_ID,
				 Base_Pay
				 Order By
					Employee_Identifier
					) row_num
From cleaning.dbo.Employee_Payroll
)

Select *
From RowNumCTE
Where row_num > 1
Order By Job_Title

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By Fiscal_Year,
				 Fiscal_Quarter,
				 Employee_Identifier,
				 Position_ID,
				 Base_Pay
				 Order By
					Employee_Identifier
					) row_num
From cleaning.dbo.Employee_Payroll
)

Delete
From RowNumCTE
Where row_num > 1
--Order By Job_Title

------------------------------------
--Delete Unused Columns

Select *
From cleaning.dbo.Employee_Payroll

Alter Table ..Employee_Payroll
Drop Column First_Name, Last_Name, Middle_Init, Fiscal_Period