# Generated by Django 2.1.1 on 2018-10-24 22:37

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('inicio', '0004_auto_20181017_1453'),
    ]

    operations = [
        migrations.CreateModel(
            name='CompMulta',
            fields=[
                ('id_comp_multa', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'comp_multa',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='CompOrden',
            fields=[
                ('id_comp_orden', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'comp_orden',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='MultaAsistencia',
            fields=[
                ('id_multa_asistencia', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'multa_asistencia',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='MultaLimpia',
            fields=[
                ('id_multa_limpia', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'multa_limpia',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='MultaOrden',
            fields=[
                ('id_multa_orden', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'multa_orden',
                'managed': False,
            },
        ),
    ]
