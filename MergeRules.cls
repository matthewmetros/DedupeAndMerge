public class MergeRules 
{
    public static Map<String, Set<String>> MergeRules(String sObjectType) 
    {

        Map<String, Set<String>> m = new Map<String, Set<String>>();

        if(sObjectType == 'Contact')
        {
            m = new Map<String, Set<String>>{  'newer' =>  new Set<String>{
                'salesloft_stage__c',
                'most_recent_cadence_cadence_name__c', 
                'most_recent_cadence_cadence_id__c', 
                'most_recent_cadence_last_completed_step__c', 
                'most_recent_cadence_next_step_due_date__c', 
                'most_recent_cadence_next_step__c', 
                'power_units__c', 
                'do_not_contact__c', 
                'econtacts__business_card__c', 
                'econtacts__created_by_econtacts__c', 
                'econtacts__location__c', 
                'econtacts__location__latitude__s', 
                'econtacts__location__longitude__s', 
                'econtacts__location_text__c', 
                'econtacts__secondary_image__c', 
                'lid__linkedin_member_token__c', 
                'lid__linkedin_company_id__c', 
                'zisf__zoom_clean_status__c', 
                'zisf__zoominfo_complete_status__c', 
                'zisf__zoom_id__c', 
                'zisf__zoom_lastupdated__c', 
                'zisf__zoominfo_phone__c', 
                'zisf__zoominfo_email__c', 
                'zisf__person_has_moved__c', 
                'zisf__zoominfo_last_clean_run__c'}
        };
            return m;
        }
        if(sObjectType == 'Lead')
        {

            m = new Map<String, Set<String>>{  'newer' =>  new Set<String>{
                'email_category__c', 
                'round_robin_id__c', 
                'round_robin_lead_number__c', 
                'do_not_auto_follow_up_in_salesloft__c', 
                'do_not_contact__c', 
                'salesloft_stage__c', 
                'most_recent_cadence_cadence_name__c', 
                'most_recent_cadence_cadence_id__c', 
                'most_recent_cadence_last_completed_step__c', 
                'ftl_per_month__c', 
                'percent_contract_loads__c', 
                'most_recent_cadence_next_step__c', 
                'most_recent_cadence_next_step_due_date__c', 
                'cargo_value__c', 
                'override_lead_assignment__c', 
                'power_units__c',
                'special_invoicing_requirements__c', 
                'dnbi__commercial_credit_score_class__c', 
                'dnbi__commercial_credit_score_percentiles__c', 
                'dnbi__commercialcreditscore__c', 
                'dnbi__d_b_address__c', 
                'dnbi__d_b_city__c', 
                'dnbi__d_b_country__c', 
                'dnbi__d_b_state_province__c', 
                'dnbi__d_b_zip_postal_code__c', 
                'dnbi__dnb_application_created_date__c', 
                'dnbi__dnb_application_id__c', 
                'dnbi__dnb_application_modified_date__c', 
                'dnbi__dnb_company_name__c', 
                'dnbi__dnb_credit_limit__c', 
                'dnbi__dnb_credit_term_status__c', 
                'dnbi__dnb_duns_no__c', 
                'dnbi__dnb_early_payment_discount__c', 
                'dnbi__dnb_payment_terms__c', 
                'dnbi__dnb_requested_amount__c', 
                'dnbi__dnb_status__c', 
                'dnbi__employees__c', 
                'dnbi__financial_stress_score__c', 
                'dnbi__financial_stress_score_class__c', 
                'dnbi__financial_stress_score_percentile__c', 
                'dnbi__paydex__c', 
                'dnbi__primary_naics__c', 
                'dnbi__primary_sic__c', 
                'dnbi__rating__c', 
                'dnbi__viability_company_profile__c', 
                'dnbi__viability_data_depth_indicator__c', 
                'dnbi__viability_portfolio_comparison__c', 
                'dnbi__viability_rating__c', 
                'dnbi__viability_viability_score__c', 
                'dnbi__years_in_business__c', 
                'econtacts__business_card__c', 
                'econtacts__created_by_econtacts__c', 
                'econtacts__location__c', 
                'econtacts__location__latitude__s', 
                'econtacts__location__longitude__s', 
                'econtacts__location_text__c', 
                'econtacts__secondary_image__c', 
                'lid__linkedin_member_token__c', 
                'lid__linkedin_company_id__c', 
                'zisf__zoom_clean_status__c', 
                'zisf__zoominfo_complete_status__c', 
                'zisf__zoom_id__c', 
                'zisf__zoom_lastupdated__c', 
                'zisf__zoominfo_industry__c', 
                'zisf__zoominfo_phone__c', 
                'zisf__zoominfo_email__c', 
                'zisf__person_has_moved__c', 
                'zisf__zoominfo_last_clean_run__c', 
                'zisf__zoominfo_trigger__c'}
        };

            return m;
        }
        if(sObjectType =='LeadContact')
        {
            m = new Map<String, Set<String>>{  'newer' =>  new Set<String>{
                'salesloft_stage__c',
                'most_recent_cadence_cadence_name__c', 
                'most_recent_cadence_cadence_id__c', 
                'most_recent_cadence_last_completed_step__c', 
                'most_recent_cadence_next_step_due_date__c', 
                'most_recent_cadence_next_step__c', 
                'power_units__c', 
                'do_not_contact__c', 
                'econtacts__business_card__c', 
                'econtacts__created_by_econtacts__c', 
                'econtacts__location__c', 
                'econtacts__location__latitude__s', 
                'econtacts__location__longitude__s', 
                'econtacts__location_text__c', 
                'econtacts__secondary_image__c', 
                'lid__linkedin_member_token__c', 
                'lid__linkedin_company_id__c', 
                'zisf__zoom_clean_status__c', 
                'zisf__zoominfo_complete_status__c', 
                'zisf__zoom_id__c', 
                'zisf__zoom_lastupdated__c', 
                'zisf__zoominfo_phone__c', 
                'zisf__zoominfo_email__c', 
                'zisf__person_has_moved__c', 
                'zisf__zoominfo_last_clean_run__c'    }
        };
            return m;
        }
        return m;
    }


}
