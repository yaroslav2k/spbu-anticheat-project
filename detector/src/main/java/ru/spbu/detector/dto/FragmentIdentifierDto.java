package ru.spbu.detector.dto;

public class FragmentIdentifierDto {
    private String fileName;
    private String className;
    private String functionName;

    public String getFileName() {
        return fileName;
    }

    public String getClassName() {
        return className;
    }

    public String getFunctionName() {
        return functionName;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        FragmentIdentifierDto that = (FragmentIdentifierDto) o;

        if (!fileName.equals(that.fileName)) return false;
        if (!className.equals(that.className)) return false;
        return functionName.equals(that.functionName);
    }

    @Override
    public int hashCode() {
        int result = fileName.hashCode();
        result = 31 * result + className.hashCode();
        result = 31 * result + functionName.hashCode();
        return result;
    }
}
