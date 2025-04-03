defmodule Recruitment.AI.CVSummarizerTest do
  use Recruitment.DataCase

  alias Recruitment.AI.CVSummarizer

  describe "cleanup_summary/1" do
    test "properly trims the text" do
      assert CVSummarizer.cleanup_summary("  Test summary.  ") == "Test summary."
    end

    test "removes incomplete sentences at the end" do
      assert CVSummarizer.cleanup_summary("Complete sentence one. Complete sentence two. Incomplete") == 
             "Complete sentence one. Complete sentence two."
    end

    test "preserves the text if there are no incomplete sentences" do
      assert CVSummarizer.cleanup_summary("All complete. No issues here.") == 
             "All complete. No issues here."
    end

    test "handles different sentence terminators" do
      assert CVSummarizer.cleanup_summary("Question? Exclamation! Incomplete") == 
             "Question? Exclamation!"
    end
  end

  describe "generate_mock_summary/1" do
    test "generates a mock summary with the expected sections" do
      resume_text = """
      JOHN DOE
      Software Engineer
      
      EXPERIENCE
      Senior Developer at Tech Company (2020-Present)
      - Led development of cloud-based applications
      - Implemented CI/CD pipelines
      
      SKILLS
      - Programming: Elixir, JavaScript, Python
      - Frameworks: Phoenix, React
      
      EDUCATION
      Bachelor of Science in Computer Science
      University of Technology (2014-2018)
      """
      
      summary = CVSummarizer.generate_mock_summary(resume_text)
      
      # Check for expected sections
      assert String.contains?(summary, "Professional Summary")
      assert String.contains?(summary, "Skills")
      assert String.contains?(summary, "Education")
      
      # Check for content from the resume
      assert String.contains?(summary, "Developer")
      assert String.contains?(summary, "Programming")
      assert String.contains?(summary, "University")
    end
    
    test "handles empty or minimal input" do
      minimal_text = "John Doe, Developer"
      summary = CVSummarizer.generate_mock_summary(minimal_text)
      
      # Should still generate a structured summary
      assert String.contains?(summary, "Professional Summary")
      assert String.contains?(summary, "Skills")
      assert String.contains?(summary, "Education")
    end
  end
  
  describe "summarize/1" do
    test "returns error for empty text" do
      assert {:error, _} = CVSummarizer.summarize("")
      assert {:error, _} = CVSummarizer.summarize("   ")
    end
    
    test "returns a summary for valid text" do
      resume_text = """
      JOHN DOE
      Software Engineer
      
      EXPERIENCE
      Senior Developer at Tech Company (2020-Present)
      - Led development of cloud-based applications
      - Implemented CI/CD pipelines
      
      SKILLS
      - Programming: Elixir, JavaScript, Python
      - Frameworks: Phoenix, React
      
      EDUCATION
      Bachelor of Science in Computer Science
      University of Technology (2014-2018)
      """
      
      # This will use the mock implementation in test environment
      assert {:ok, summary} = CVSummarizer.summarize(resume_text)
      assert is_binary(summary)
      assert String.length(summary) > 0
    end
  end
  
  # Test the keywords extraction indirectly through the mock summary
  describe "keyword extraction" do
    test "identifies keywords from different resume sections" do
      resume_text = """
      EXPERIENCE
      work with JavaScript development
      job involves Python programming
      
      SKILLS
      skill in database design
      technology includes AWS and Docker
      
      EDUCATION
      university degree in Computer Science
      college courses in Mathematics
      """
      
      summary = CVSummarizer.generate_mock_summary(resume_text)
      
      # Check that keywords from each section were extracted
      assert String.contains?(summary, "Javascript") or 
             String.contains?(summary, "Python") or 
             String.contains?(summary, "Development")
      
      assert String.contains?(summary, "Database") or 
             String.contains?(summary, "Design") or 
             String.contains?(summary, "Technology")
      
      assert String.contains?(summary, "University") or 
             String.contains?(summary, "College") or 
             String.contains?(summary, "Computer") or
             String.contains?(summary, "Science")
    end
  end
end
