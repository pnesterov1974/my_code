using System;
using System.Windows.Forms;

namespace winFormsApp
{
    public partial class firstForm : Form
    {
        private static string ConnectionString;
        public firstForm()
        {
            InitializeComponent();
        }

        public firstForm(string connStr)
        {
            firstForm.ConnectionString = connStr;
            InitializeComponent();
        }

        private void firstForm_Load(object sender, EventArgs e)
        {
            DbReader dbr = new DbReader(firstForm.ConnectionString);
            dbr.ReadData();
            foreach (DbRecord rec in dbr.Data)
            {
                dataGridView.Rows.Add(rec.TableName, rec.SchemaName, rec.Rows, rec.TotalSpaceKB, rec.UnusedSpaceMB, rec.UsedSpaceKB, rec.UsedSpaceMB, rec.UnusedSpaceKB, rec.UnusedSpaceMB);
            }
        }

        private void dataGridView_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {
            //DataGridView sender as DataGridView;
            if (this.dataGridView.Columns[e.ColumnIndex].Name == "TableName")
            {
                this.dataGridView.Rows[e.RowIndex].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleLeft;
                //if (e.Value != null && e.Value.ToString() == "1")
                //{
                //    dataGridView1.Rows[e.RowIndex].DefaultCellStyle.ForeColor = Color.Red;
                //}
            }
            else
            {
                this.dataGridView.Rows[e.RowIndex].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            }
        }
    }
}
