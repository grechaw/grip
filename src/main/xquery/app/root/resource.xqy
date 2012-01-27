xquery version "1.0-ml" encoding "utf-8";

(:
 : Action's variables and parameters.
 : @author	Philip A. R. Fennell
 :)

module namespace resource = "http://www.grip.com";

(:~ The original, in-coming, request URI. :)
declare variable $resource:REQUEST_URI as xs:string external;

(:~ The 'path' portion of the original, in-coming, request URI. :)
declare variable $resource:REQUEST_PATH as xs:string external;

(:~ Request payload. :)
declare variable $resource:CONTENT as item()? external;

(:~ Request payload media-type. :)
declare variable $resource:MEDIA_TYPE as xs:string? external;

(:~ Request Slug header - a suggested name/suffix for the new graph URI. :)
declare variable $resource:SLUG as xs:string? external;
