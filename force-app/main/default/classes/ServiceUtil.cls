/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          11/29/2019
*   @TaskSource:    Jira
*   @Purpose:       Utility class for common methods to use in all web service classes
*
*   @Updates:       
*/
public with sharing class ServiceUtil 
{

    // Remove all charachters other than Numbers 
    public static String formatPhone(String phone)
    {
        return phone.replaceAll('\\D','');
    }

    // Check a string for null value
    public static String checkNull(String str )
    {
        return String.isBlank(str) ? '' : str ;
    }

    // To remove extra charachters from Zipcode when zipcode comes in like this 90002-4524   
    public static String trimZipCode(String zipcode)
    {
        if(String.isBlank(zipcode)) return '' ;
        return zipcode.indexOf('-') > 0 && zipcode.length() > 5  ? zipcode.left(5) : zipcode ;
    }

    public Static String addSoslWildcards(String s) {
        String r = '*';
        for (Integer i = 0; i < s.length(); i++) {
            r += s.substring(i, i + 1) + '*';
        }
        return r;
    }
    static Pattern emailPattern = Pattern.compile('(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])');
    public static Boolean isValidEmail(String email) {
        return emailPattern.matcher(email).matches();
    }

    //Method to Concatenate Phone fields with a hyphen
    public static String concatenatePhoneNumbers(List<String> phones) {
        String concatenatedPhones = '';
        boolean isFirstNumber = true;

        for (String phone : phones) {
            if (phone == null) {
                continue;
            }
            String cleanedPhone = formatPhone(phone);
            
            if (!isFirstNumber) {
                concatenatedPhones += '-';
            } else {
                isFirstNumber = false;
            }
            concatenatedPhones += cleanedPhone;
        }
        return concatenatedPhones;
    }
}