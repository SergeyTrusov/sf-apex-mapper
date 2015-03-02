public class GS_StringBuilder {

    public static final String EMPTY_STRING = '';

    private String[] values;

    public GS_StringBuilder() {
        values = new List<String>();
    }

    public GS_StringBuilder(String value) {
        this.values = new List<String>();
        this.values.add(value);
    }

    public GS_StringBuilder(String[] values) {
        this.values = new List<String>();
        this.values.addAll(values);
    }

    public void add(String value) {
        this.values.add(value);
    }

    public void add(String[] values) {
        this.values.addAll(values);
    }

    public String build() {
        return String.join(values, EMPTY_STRING);
    }

}