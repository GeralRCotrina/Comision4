# Generated by Django 2.1.1 on 2018-10-11 15:38

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('usuario', '0004_auto_20181011_1038'),
        ('canalero', '0001_initial'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Reparto',
        ),
    ]
