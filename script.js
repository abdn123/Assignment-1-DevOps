function filterProjects() {
    let input, filter, projects, project, tech, i, txtValue;
    input = document.getElementById('filter');
    filter = input.value.toUpperCase();
    projects = document.querySelectorAll('.projects .project');
  
    for (i = 0; i < projects.length; i++) {
      project = projects[i];
      tech = project.querySelector('.technology');
      txtValue = tech.textContent || tech.innerText;
      
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        project.style.display = '';
      } else {
        project.style.display = 'none';
      }
    }
  }
  