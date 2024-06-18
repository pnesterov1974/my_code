
namespace winFormsApp
{
    partial class firstForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.panel1 = new System.Windows.Forms.Panel();
            this.dataGridView = new System.Windows.Forms.DataGridView();
            this.TableName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.SchemaName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Rows = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.TotalSpaceKB = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.TotalSpaceMB = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.UsedSpaceKB = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.UsedSpaceMB = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.UnusedSpaceKB = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.UnusedSpeceMB = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1438, 66);
            this.panel1.TabIndex = 0;
            // 
            // dataGridView
            // 
            this.dataGridView.AllowUserToOrderColumns = true;
            this.dataGridView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.DisplayedCells;
            this.dataGridView.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.DisplayedHeaders;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dataGridView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.TableName,
            this.SchemaName,
            this.Rows,
            this.TotalSpaceKB,
            this.TotalSpaceMB,
            this.UsedSpaceKB,
            this.UsedSpaceMB,
            this.UnusedSpaceKB,
            this.UnusedSpeceMB});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dataGridView.DefaultCellStyle = dataGridViewCellStyle2;
            this.dataGridView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dataGridView.Location = new System.Drawing.Point(0, 66);
            this.dataGridView.Name = "dataGridView";
            this.dataGridView.RowHeadersWidth = 51;
            this.dataGridView.RowTemplate.DefaultCellStyle.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.dataGridView.RowTemplate.DefaultCellStyle.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.dataGridView.RowTemplate.Height = 24;
            this.dataGridView.RowTemplate.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.dataGridView.Size = new System.Drawing.Size(1438, 622);
            this.dataGridView.TabIndex = 1;
            this.dataGridView.CellFormatting += new System.Windows.Forms.DataGridViewCellFormattingEventHandler(this.dataGridView_CellFormatting);
            // 
            // TableName
            // 
            this.TableName.Frozen = true;
            this.TableName.HeaderText = "TableName";
            this.TableName.MinimumWidth = 6;
            this.TableName.Name = "TableName";
            this.TableName.Width = 110;
            // 
            // SchemaName
            // 
            this.SchemaName.Frozen = true;
            this.SchemaName.HeaderText = "SchemaName";
            this.SchemaName.MinimumWidth = 6;
            this.SchemaName.Name = "SchemaName";
            this.SchemaName.Width = 125;
            // 
            // Rows
            // 
            this.Rows.Frozen = true;
            this.Rows.HeaderText = "RowCount";
            this.Rows.MinimumWidth = 6;
            this.Rows.Name = "Rows";
            this.Rows.Width = 101;
            // 
            // TotalSpaceKB
            // 
            this.TotalSpaceKB.HeaderText = "Total Space KB";
            this.TotalSpaceKB.MinimumWidth = 6;
            this.TotalSpaceKB.Name = "TotalSpaceKB";
            this.TotalSpaceKB.Width = 135;
            // 
            // TotalSpaceMB
            // 
            this.TotalSpaceMB.HeaderText = "Total Space MB";
            this.TotalSpaceMB.MinimumWidth = 6;
            this.TotalSpaceMB.Name = "TotalSpaceMB";
            this.TotalSpaceMB.Width = 137;
            // 
            // UsedSpaceKB
            // 
            this.UsedSpaceKB.HeaderText = "Used Space KB";
            this.UsedSpaceKB.MinimumWidth = 6;
            this.UsedSpaceKB.Name = "UsedSpaceKB";
            this.UsedSpaceKB.Width = 136;
            // 
            // UsedSpaceMB
            // 
            this.UsedSpaceMB.HeaderText = "USed Space MB";
            this.UsedSpaceMB.MinimumWidth = 6;
            this.UsedSpaceMB.Name = "UsedSpaceMB";
            this.UsedSpaceMB.Width = 140;
            // 
            // UnusedSpaceKB
            // 
            this.UnusedSpaceKB.HeaderText = "Unused Space KB";
            this.UnusedSpaceKB.MinimumWidth = 6;
            this.UnusedSpaceKB.Name = "UnusedSpaceKB";
            this.UnusedSpaceKB.Width = 152;
            // 
            // UnusedSpeceMB
            // 
            this.UnusedSpeceMB.HeaderText = "Unused Space MB";
            this.UnusedSpeceMB.MinimumWidth = 6;
            this.UnusedSpeceMB.Name = "UnusedSpeceMB";
            this.UnusedSpeceMB.ToolTipText = "Unused Space MB";
            this.UnusedSpeceMB.Width = 154;
            // 
            // firstForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1438, 688);
            this.Controls.Add(this.dataGridView);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.Name = "firstForm";
            this.Text = "firstForm";
            this.Load += new System.EventHandler(this.firstForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.DataGridView dataGridView;
        private System.Windows.Forms.DataGridViewTextBoxColumn TableName;
        private System.Windows.Forms.DataGridViewTextBoxColumn SchemaName;
        private System.Windows.Forms.DataGridViewTextBoxColumn Rows;
        private System.Windows.Forms.DataGridViewTextBoxColumn TotalSpaceKB;
        private System.Windows.Forms.DataGridViewTextBoxColumn TotalSpaceMB;
        private System.Windows.Forms.DataGridViewTextBoxColumn UsedSpaceKB;
        private System.Windows.Forms.DataGridViewTextBoxColumn UsedSpaceMB;
        private System.Windows.Forms.DataGridViewTextBoxColumn UnusedSpaceKB;
        private System.Windows.Forms.DataGridViewTextBoxColumn UnusedSpeceMB;
    }
}