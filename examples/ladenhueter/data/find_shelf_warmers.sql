with input as (SELECT * from "<source_table_name>"),
     all_with_rownumber as (
        select *,
        row_number() OVER (partition by sku, location order by "updated_at" desc) as row_number
        from input
     ),
     potential_ladenhueter as (
        select sku, location, available, updated_at
        from all_with_rownumber
        where row_number = 1 and available > 0
        order by sku, location
     ),
     all_with_aenderungen as (
        select *,
        available - COALESCE(lead(available) OVER(
            partition by sku,
            location order by "updated_at" desc
        ), 0) as delta
        from input
     ),
     all_abgaenge_last_three_month as (
        select *
        from all_with_aenderungen
        where delta < 0 and updated_at between
            from_iso8601_timestamp('2007-10-01T00:00:00Z') and
            from_iso8601_timestamp('2008-01-01T00:00:00Z')
     )

select potential_ladenhueter.sku,
       potential_ladenhueter.location,
       potential_ladenhueter.available,
       potential_ladenhueter.updated_at
from potential_ladenhueter
         left outer join all_abgaenge_last_three_month on
            potential_ladenhueter.sku = all_abgaenge_last_three_month.sku and
            potential_ladenhueter.location = all_abgaenge_last_three_month.location
order by potential_ladenhueter.sku, potential_ladenhueter.location
