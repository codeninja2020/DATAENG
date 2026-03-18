#!/usr/bin/env python3
"""
COMPLETE WORKFLOW DEMO
Shows end-to-end validation and processing with database integration example.
"""

import pandas as pd
from streamhsbc import validate_chunk, MANDATORY_FIELDS

def demo_complete_workflow():
    """
    Demonstrates complete ETL workflow with validation:
    1. Read data in chunks
    2. Validate each chunk against mandatory fields
    3. Separate valid/invalid rows
    4. Process valid rows (database load)
    5. Log invalid rows for review
    """

    print("="*80)
    print("COMPLETE ETL WORKFLOW WITH ROW VALIDATION")
    print("="*80)

    # Simulated file processing
    test_file = 'member_details_sample.txt'

    print(f"\n📂 Processing file: {test_file}")
    print(f"📋 Validation rules: {len(MANDATORY_FIELDS)} mandatory fields")
    print(f"⚙️  Chunk size: 10,000 rows\n")

    # Process in chunks (production would use actual large file)
    try:
        df_iterator = pd.read_csv(test_file, sep='|', engine='python',
                                   encoding='utf-8', chunksize=10000)

        total_valid = 0
        total_invalid = 0
        total_rows = 0
        all_chunks_results = []

        for i, chunk in enumerate(df_iterator):
            chunk_num = i + 1
            print(f"{'─'*80}")
            print(f"📦 CHUNK {chunk_num}: {len(chunk)} rows")
            print(f"{'─'*80}")

            # ★ VALIDATE THE CHUNK ★
            results = validate_chunk(chunk, MANDATORY_FIELDS, chunk_num)

            # Track statistics
            total_rows += results['total_rows']
            total_valid += results['valid_rows']
            total_invalid += results['invalid_rows']
            all_chunks_results.append(results)

            # Show results
            print(f"  ✓ Valid:   {results['valid_rows']:>5} rows")
            print(f"  ✗ Invalid: {results['invalid_rows']:>5} rows")

            if results['errors']:
                print(f"\n  ⚠️  Errors (first 5):")
                for error in results['errors'][:5]:
                    print(f"     • {error}")
                if len(results['errors']) > 5:
                    print(f"     ... and {len(results['errors']) - 5} more")

            # Separate valid and invalid rows
            valid_chunk = chunk.loc[results['valid_indices']]
            invalid_chunk = chunk.loc[results['invalid_indices']]

            # PROCESS VALID ROWS
            if not valid_chunk.empty:
                print(f"\n  💾 Loading {len(valid_chunk)} valid rows to database...")
                # In production: load_to_database(valid_chunk)
                # Example: bulk_insert_to_sql_server(valid_chunk)
                print(f"  ✅ Successfully loaded chunk {chunk_num}")

            # HANDLE INVALID ROWS
            if not invalid_chunk.empty:
                error_file = f'member_details_errors_chunk_{chunk_num}.csv'
                invalid_chunk.to_csv(error_file, sep='|', index=False)
                print(f"  📝 Invalid rows saved to: {error_file}")

            print()

        # FINAL SUMMARY
        print("="*80)
        print("FINAL SUMMARY")
        print("="*80)
        print(f"\n📊 Total rows processed: {total_rows:,}")
        print(f"   ✓ Valid rows:         {total_valid:,} ({total_valid/total_rows*100:.2f}%)")
        print(f"   ✗ Invalid rows:       {total_invalid:,} ({total_invalid/total_rows*100:.2f}%)")

        print(f"\n🎯 Data Quality Score: {total_valid/total_rows*100:.1f}%")

        if total_invalid > 0:
            print(f"\n⚠️  Action Required:")
            print(f"   • Review {total_invalid} invalid rows in error CSV files")
            print(f"   • Correct data issues at source")
            print(f"   • Re-run validation after corrections")
        else:
            print(f"\n🎉 Perfect! All rows passed validation.")

        print("\n" + "="*80)

    except FileNotFoundError:
        print(f"\n❌ File not found: {test_file}")
        print("   Create the file or update the path in the script.")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()


def demo_database_integration():
    """
    Example: How to integrate validation with SQL Server load
    """
    print("\n" + "="*80)
    print("DATABASE INTEGRATION EXAMPLE")
    print("="*80)

    print("""
The validation system integrates seamlessly with your SQL Server pipeline:

OPTION 1: Python → SQL Server (pyodbc)
```python
import pyodbc
from streamhsbc import validate_chunk, MANDATORY_FIELDS

conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};...')
cursor = conn.cursor()

df_iterator = pd.read_csv('member_details.txt', sep='|', chunksize=10000)

for i, chunk in enumerate(df_iterator):
    results = validate_chunk(chunk, MANDATORY_FIELDS, i+1)
    valid_chunk = chunk.loc[results['valid_indices']]
    
    # Insert only valid rows
    for idx, row in valid_chunk.iterrows():
        cursor.execute('''
            INSERT INTO django.member_details 
            (id, email, first_name, last_name, address_line_1, ...)
            VALUES (?, ?, ?, ?, ?, ...)
        ''', row['id'], row['email'], row['first_name'], ...)
    
    conn.commit()
```

OPTION 2: Validate → Save Clean CSV → BULK INSERT in SQL
```python
# Step 1: Validate and save only valid rows
for i, chunk in enumerate(df_iterator):
    results = validate_chunk(chunk, MANDATORY_FIELDS, i+1)
    valid_chunk = chunk.loc[results['valid_indices']]
    
    if not valid_chunk.empty:
        valid_chunk.to_csv(f'validated_chunk_{i}.csv', sep='|', 
                          index=False, header=(i==0))

# Step 2: In SQL Server - Load validated data
BULK INSERT django.member_details
FROM 'D:\\validated_data\\validated_chunk_0.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);
```

OPTION 3: Integrate with Your RDS S3 Pipeline
```python
# After S3 download completes (from dhango_agent_jobscript13.sql)
# Add Python validation step before BULK INSERT:

# 1. Download files from S3 (your SQL proc)
# 2. Validate downloaded files with Python
for file in downloaded_files:
    df = pd.read_csv(file, sep='|', chunksize=10000)
    for chunk in df:
        results = validate_chunk(chunk, rules, ...)
        if results['valid_rows'] > 0:
            # Save validated data
            # Then BULK INSERT in SQL
        if results['invalid_rows'] > 0:
            # Log to django.S3_Load_Tracking with error details

# 3. Load validated data (your SQL proc continues)
```
    """)


if __name__ == '__main__':
    demo_complete_workflow()
    demo_database_integration()

    print("\n" + "="*80)
    print("🎓 LEARN MORE")
    print("="*80)
    print("""
📖 Documentation files:
   • IMPLEMENTATION_SUMMARY.md  - This implementation overview
   • VALIDATION_README.md       - Complete technical documentation
   • VALIDATION_QUICKSTART.md   - Quick start guide

🧪 Test scripts:
   • test_validation.py         - Test with sample data
   • example_validation.py      - Advanced examples

⚙️  Production scripts:
   • streamhsbc.py              - Main validation engine
   • validation_config.py       - Validation rules dictionary

Run any script with: python3 <script_name>.py
    """)

