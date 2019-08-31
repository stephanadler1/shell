public class javaSelfTest {
    public static void main(String args[]) 
    {
        System.out.println("Hello Java!");

        // From https://stackoverflow.com/questions/18888220/how-to-check-whether-java-is-installed-on-the-computer
        System.out.format("java.version:         %s%n", System.getProperty("java.version"));
        System.out.format("java.runtime.version: %s%n", System.getProperty("java.runtime.version"));
        System.out.format("java.home:            %s%n", System.getProperty("java.home"));
        System.out.format("java.vendor:          %s%n", System.getProperty("java.vendor"));
        System.out.format("java.vendor.url:      %s%n", System.getProperty("java.vendor.url"));
        System.out.format("java.class.path:      %s%n", System.getProperty("java.class.path"));

        // System.out.println(System.getProperty("java.version"));
        // System.out.println(System.getProperty("java.runtime.version"));
        // System.out.println(System.getProperty("java.home"));
        // System.out.println(System.getProperty("java.vendor"));
        // System.out.println(System.getProperty("java.vendor.url"));
        // System.out.println(System.getProperty("java.class.path"));
    }
}
