import pandas as pd
import numpy as np
import os
import warnings

# Suprimir advertencias específicas de openpyxl
warnings.filterwarnings("ignore", category=UserWarning, module="openpyxl")

# Definir rutas de salida
OUTPUT_DIR = 'output'
VALIDATION_DIR = os.path.join(OUTPUT_DIR, 'validations')
CORRECTED_DIR = os.path.join(OUTPUT_DIR, 'corrected')

# Crear las carpetas de salida si no existen
os.makedirs(VALIDATION_DIR, exist_ok=True)
os.makedirs(CORRECTED_DIR, exist_ok=True)

# Validation Functions
def validate_text(column):
    return column.apply(lambda x: isinstance(x, str) or pd.isnull(x))

def validate_date(column):
    # Parse dates assuming 'mm/dd/yyyy' format as in your data
    parsed_dates = pd.to_datetime(column, format='%m/%d/%Y', errors='coerce')
    return parsed_dates.notna()

valid_motivos = [
    'PERSONA MAYOR DE 60 AÑOS',
    'PERSONA CON ENFERMEDAD CRÓNICA',
    'PERSONA CON DISCAPACIDAD',
    'GESTANTE',
    'USUARIO QUE INTERPUSO PQRS',
    'OTRO'
]

def validate_motivo(column):
    return column.isin(valid_motivos)

valid_document_types = ['CC', 'TI', 'RC', 'CE', 'PEP', 'DNI', 'SCR', 'PA']

def validate_document_type(column):
    return column.isin(valid_document_types)

valid_localities = [
    'USAQUÉN', 'CHAPINERO', 'SANTA FE', 'SAN CRISTÓBAL', 'USME',
    'TUNJUELITO', 'BOSA', 'KENNEDY', 'FONTIBÓN', 'ENGATIVÁ',
    'SUBA', 'BARRIOS UNIDOS', 'TEUSAQUILLO', 'LOS MÁRTIRES',
    'ANTONIO NARIÑO', 'PUENTE ARANDA', 'LA CANDELARIA',
    'RAFAEL URIBE URIBE', 'CIUDAD BOLÍVAR', 'SUMAPAZ'
]

def validate_locality(column):
    return column.isin(valid_localities)

valid_subred = ['SUR', 'NORTE', 'SUR OCCIDENTE', 'CENTRO ORIENTE']

def validate_subred(column):
    return column.isin(valid_subred)

def validate_poblacion_priorizada(row):
    motivo = row['MOTIVO DE ENTREGA']
    poblacion_priorizada = row['POBLACION PRIORIZADA']
    if motivo in valid_motivos[:4]:
        return poblacion_priorizada.strip().upper() == 'SI'
    elif motivo in valid_motivos[4:]:
        return poblacion_priorizada.strip().upper() == 'NO'
    else:
        return False

# Correction Functions
def correct_text(column):
    return column.fillna('').astype(str).str.strip()

def correct_date(column):
    # Parse the date assuming 'mm/dd/yyyy' format
    corrected_dates = pd.to_datetime(column, format='%m/%d/%Y', errors='coerce')
    # Now format to 'dd/mm/yyyy' as required
    return corrected_dates.dt.strftime('%d/%m/%Y')

def correct_motivo(column):
    return column.str.upper().str.strip()

def correct_poblacion_priorizada(row):
    motivo = row['MOTIVO DE ENTREGA']
    if motivo in valid_motivos[:4]:
        return 'SI'
    elif motivo in valid_motivos[4:]:
        return 'NO'
    else:
        return row['POBLACION PRIORIZADA']

# Validation Function for Entire DataFrame
def validate_dataframe(df):
    validation_results = pd.DataFrame()

    for column in ['PRIMER NOMBRE', 'SEGUNDO NOMBRE', 'PRIMER APELLIDO', 'SEGUNDO APELLIDO']:
        if column in df.columns:
            validation_results[column] = validate_text(df[column])
        else:
            validation_results[column] = False  # Columna faltante

    for column in ['FECHA DE NACIMIENTO', 'FECHA DE ENTREGA', 'FECHA DE LA ORDEN MEDICA']:
        if column in df.columns:
            validation_results[column] = validate_date(df[column])
        else:
            validation_results[column] = False  # Columna faltante

    # Validar otras columnas
    columnas_a_validar = {
        'MOTIVO DE ENTREGA': validate_motivo,
        'TIPO DE DOCUMENTO': validate_document_type,
        'NOMBRE LOCALIDAD RESIDENCIA': validate_locality,
        'NOMBRE DE SUBRED QUE ENTREGA': validate_subred
    }

    for column, func in columnas_a_validar.items():
        if column in df.columns:
            validation_results[column] = func(df[column])
        else:
            validation_results[column] = False  # Columna faltante

    # Validar 'POBLACION PRIORIZADA'
    if 'POBLACION PRIORIZADA' in df.columns and 'MOTIVO DE ENTREGA' in df.columns:
        validation_results['POBLACION PRIORIZADA'] = df.apply(validate_poblacion_priorizada, axis=1)
    else:
        validation_results['POBLACION PRIORIZADA'] = False  # Columnas faltantes

    return validation_results

# Correction Function for Entire DataFrame
def correct_dataframe(df):
    corrected_df = df.copy()

    for column in ['PRIMER NOMBRE', 'SEGUNDO NOMBRE', 'PRIMER APELLIDO', 'SEGUNDO APELLIDO']:
        if column in corrected_df.columns:
            corrected_df[column] = correct_text(corrected_df[column])

    for column in ['FECHA DE NACIMIENTO', 'FECHA DE ENTREGA', 'FECHA DE LA ORDEN MEDICA']:
        if column in corrected_df.columns:
            corrected_df[column] = correct_date(corrected_df[column])

    if 'MOTIVO DE ENTREGA' in corrected_df.columns:
        corrected_df['MOTIVO DE ENTREGA'] = correct_motivo(corrected_df['MOTIVO DE ENTREGA'])

    if 'POBLACION PRIORIZADA' in corrected_df.columns and 'MOTIVO DE ENTREGA' in corrected_df.columns:
        corrected_df['POBLACION PRIORIZADA'] = corrected_df.apply(correct_poblacion_priorizada, axis=1)

    return corrected_df

# Main Script
if __name__ == '__main__':
    try:
        # Cargar Datos
        capital_df = pd.read_excel('Capital.xlsx', dtype=str)
        sur_df = pd.read_excel('SUR.xlsx', dtype=str)

        # Eliminar espacios en los nombres de las columnas
        capital_df.columns = capital_df.columns.str.strip().str.upper()
        sur_df.columns = sur_df.columns.str.strip().str.upper()

        # Validar Datos
        capital_validation = validate_dataframe(capital_df)
        sur_validation = validate_dataframe(sur_df)

        # Guardar Resultados de Validación en Carpeta 'validations'
        capital_validation_path = os.path.join(VALIDATION_DIR, 'Capital_Validation.xlsx')
        sur_validation_path = os.path.join(VALIDATION_DIR, 'SUR_Validation.xlsx')
        capital_validation.to_excel(capital_validation_path, index=False)
        sur_validation.to_excel(sur_validation_path, index=False)

        # Corregir Datos
        corrected_capital_df = correct_dataframe(capital_df)
        corrected_sur_df = correct_dataframe(sur_df)

        # Guardar Datos Corregidos en Carpeta 'corrected'
        corrected_capital_path = os.path.join(CORRECTED_DIR, 'Capital_Corregido.xlsx')
        corrected_sur_path = os.path.join(CORRECTED_DIR, 'SUR_Corregido.xlsx')
        corrected_capital_df.to_excel(corrected_capital_path, index=False)
        corrected_sur_df.to_excel(corrected_sur_path, index=False)

        print("Validación y corrección completadas. Archivos guardados en la carpeta 'output'.")
    except FileNotFoundError as e:
        print(f"Error: {e}. Asegúrate de que los archivos 'Capital.xlsx' y 'SUR.xlsx' estén en el directorio correcto.")
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")
